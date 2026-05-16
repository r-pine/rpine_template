# gRPC routing through edge nginx-proxy on :443
# All gRPC services are routed to app nginx ({{PROJECT_NAME}}_nginx:50052)

location ~ ^/{{PROJECT_NAME}}\. {
    grpc_pass grpc://{{PROJECT_NAME}}_nginx:50052;
    grpc_set_header Host              $host;
    grpc_set_header X-Real-IP         $remote_addr;
    grpc_set_header X-Forwarded-For   $proxy_add_x_forwarded_for;
    grpc_set_header X-Forwarded-Proto $scheme;
    grpc_read_timeout 600s;
    grpc_send_timeout 600s;
    grpc_connect_timeout 60s;
    error_page 502 = /grpc_internal_error;
}

location = /grpc_internal_error {
    internal;
    default_type application/grpc;
    add_header grpc-status 14;
    add_header grpc-message "Unavailable";
    return 204;
}
