#!/bin/sh
set -e

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
	local var="$1"
	local fileVar="${var}_FILE"
	local def="${2:-}"
	if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
		echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
		exit 1
	fi
	local val="$def"
	if [ "${!var:-}" ]; then
		val="${!var}"
	elif [ "${!fileVar:-}" ]; then
		val="$(< "${!fileVar}")"
	fi
	export "$var"="$val"
	unset "$fileVar"
}

if [ "${1:0:1}" = '-' ]; then
	set -- agraph "$@"
fi

# allow the container to be started with `--user`
if [ "$1" = 'agens-graph' ] && [ "$(id -u)" = '0' ]; then
	mkdir -p "$AGDATA"
	chown -R agraph "$AGDATA"
	chmod 700 "$AGDATA"

	mkdir -p /var/run/agens-graph
	chown -R agraph /var/run/agens-graph
	chmod g+s /var/run/agens-graph

	exec gosu agraph "$BASH_SOURCE" "$@"
fi

if [ "$1" = 'agens-graph' ]; then
	mkdir -p "$AGDATA"
	chown -R "$(id -u)" "$AGDATA" 2>/dev/null || :
	chmod 700 "$AGDATA" 2>/dev/null || :

	# look specifically for PG_VERSION, as it is expected in the DB dir
	if [ ! -s "$AGDATA/PG_VERSION" ]; then
		file_env 'AGENSGRAPH_INITDB_ARGS'
		eval "initdb --username=agraph $AGENSGRAPH_INITDB_ARGS"

		# check password first so we can output the warning before postgres
		# messes it up
		file_env 'AGENSGRAPH_PASSWORD'
		if [ "$AGENSGRAPH_PASSWORD" ]; then
			pass="PASSWORD '$AGENSGRAPH_PASSWORD'"
			authMethod=md5
		else
			# The - option suppresses leading tabs but *not* spaces. :)
			cat >&2 <<-'EOWARN'
				****************************************************
				WARNING: No password has been set for the database.
				         This will allow anyone with access to the
				         Postgres port to access your database. In
				         Docker's default configuration, this is
				         effectively any other container on the same
				         system.
				         Use "-e POSTGRES_PASSWORD=password" to set
				         it in "docker run".
				****************************************************
			EOWARN

			pass=
			authMethod=trust
		fi

		{ echo; echo "host all all all $authMethod"; } | tee -a "$AGDATA/pg_hba.conf" > /dev/null
		# internal start of server in order to allow set-up using psql-client		
		# does not listen on external TCP/IP and waits until start finishes
		PGUSER="${PGUSER:-agraph}" \
		ag_ctl -D "$AGDATA" \
			-o "-c listen_addresses='localhost'" \
			-l "$AGDATA/logfile" \
			-w start || true

		file_env 'AGENSGRAPH_USER' 'agraph'
		file_env 'AGENSGRAPH_DB' "$AGENSGRAPH_USER"
                
                createdb --owner=$AGENSGRAPH_USER $AGENSGRAPH_DB
		agens=( agens -v ON_ERROR_STOP=1 )

		if [ "$AGENSGRAPH_DB" != 'agraph' ]; then
			"${agens[@]}" --username agraph <<-EOSQL
				CREATE DATABASE "$AGENSGRAPH_DB" ;
			EOSQL
			echo
		fi

		if [ "$AGENSGRAPH_USER" = 'agraph' ]; then
			op='ALTER'
		else
			op='CREATE'
		fi
		"${agens[@]}" --username agraph <<-EOSQL
			$op USER "$AGENSGRAPH_USER" WITH SUPERUSER $pass ;
		EOSQL
		echo
		"${agens[@]}" --username agraph <<-EOSQL
			CREATE GRAPH docker_graph;
		EOSQL
                echo
		agens+=( --username "$AGENSGRAPH_USER" --dbname "$AGENSGRAPH_DB" )

		echo
		for f in /docker-entrypoint-initdb.d/*; do
			case "$f" in
				*.sh)     echo "$0: running $f"; . "$f" ;;
				*.sql)    echo "$0: running $f"; "${agens[@]}" -f "$f"; echo ;;
				*.sql.gz) echo "$0: running $f"; gunzip -c "$f" | "${agens[@]}"; echo ;;
				*)        echo "$0: ignoring $f" ;;
			esac
			echo
		done

		PGUSER="${PGUSER:-agraph}" \
		ag_ctl -D "$AGDATA" -m fast -w stop
		sed -ri "s!^#?(listen_addresses)\s*=\s*\S+.*!\1 = '*'!" /agens-graph/data/postgresql.conf
		echo
		echo 'AgensGraph init process complete; ready for start up.'
		echo
	fi
	
fi

exec "$@"
