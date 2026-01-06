# MMC-API

## The public client API for the MMC server.

MMC guidelines and documentation are automatically generated from Markdown to 
HTML using [mkdocs-material](https://github.com/squidfunk/mkdocs-material). The 
API documentation is automatically converted from Protobuf to Markdown using 
[protoc-gen-doc](https://github.com/pseudomuto/protoc-gen-doc?tab=readme-ov-file).

### Generate the Markdown file from the API
Run the following command to generate the documentation after installing [protoc-gen-doc](https://github.com/pseudomuto/protoc-gen-doc?tab=readme-ov-file):

```bash
protoc -I=protobuf --doc_out=./docs --doc_opt=markdown,protocol-documentation.md protobuf/*.proto protobuf/mmc/*.proto
```

### View Documentation

For full guidelines on how to use the API, open `site/index.html` in your 
browser.
