#!/bin/bash
# .aicheck/scripts/session.sh
# Session management for AICheck

source .aicheck/scripts/common.sh

# Start a new session
default_session_dir=".aicheck/sessions"
default_current_session_file=".aicheck/current_session"

start_session() {
    mkdir -p "$default_session_dir"
    session_id="session_$(date +%Y%m%d%H%M%S)"
    session_file="$default_session_dir/$session_id.session"
    touch "$session_file"
    echo "$session_id" > "$default_current_session_file"
    echo "Started new session: $session_id"
    echo "Session file: $session_file"
}

end_session() {
    if [[ ! -f "$default_current_session_file" ]]; then
        log_error "SESSION001" "No active session to end." "Start a session with ./ai start."
        return 1
    fi
    session_id=$(cat "$default_current_session_file")
    echo "Ended session: $session_id"
    rm -f "$default_current_session_file"
} 