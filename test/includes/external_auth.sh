# Test helper for external authentication

start_external_auth_daemon() {

    (
        cd macaroon-identity || return
        # Use -buildvcs=false here to prevent git complaining about untrusted directory when tests are run as root.
        go build -v -buildvcs=false ./...
    )
    # shellcheck disable=SC2039,3043
    local credentials_file tcp_port
    credentials_file="$1/macaroon-identity-credentials.csv"
    tcp_port="$(local_tcp_port)"
    cat <<EOF >"$credentials_file"
user1,pass1
user2,pass2
EOF

    macaroon-identity/macaroon-identity -endpoint "localhost:$tcp_port" -creds "$credentials_file" &
    set +x
    echo $! > "${TEST_DIR}/macaroon-identity.pid"
    echo "http://localhost:$tcp_port" > "${TEST_DIR}/macaroon-identity.endpoint"
}

kill_external_auth_daemon() {
    # shellcheck disable=SC2039,3043
    local pidfile="$1/macaroon-identity.pid"
    kill "$(cat "$pidfile")" || true
    rm -f macaroon-identity/macaroon-identity
}
