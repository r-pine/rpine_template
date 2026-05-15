.PHONY: generate clean

PROTO_DIR := .
GEN_DIR := ./gen

generate:
	@mkdir -p $(GEN_DIR)
	protoc \
		--go_out=$(GEN_DIR) \
		--go_opt=paths=source_relative \
		--go-grpc_out=$(GEN_DIR) \
		--go-grpc_opt=paths=source_relative \
		$(PROTO_DIR)/*.proto
	@echo "Proto files generated in $(GEN_DIR)"

clean:
	rm -rf $(GEN_DIR)
