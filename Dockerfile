# 1) Base image with Python
FROM python:3.12-slim

# 2) Install system deps + Node 20 (needed for @azure-devops/mcp)
RUN apt-get update && apt-get install -y curl ca-certificates gnupg \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# 3) Install mcp-proxy (SSE <-> stdio bridge)
RUN pip install --no-cache-dir mcp-proxy

# 4) Default PORT; Render will override with its own $PORT
ENV PORT=8080

# 5) Expose the port
EXPOSE 8080

# 6) Start mcp-proxy (SSE server) exposing the stdio Azure DevOps MCP server
#    --host 0.0.0.0       => listen on all interfaces in the container
#    --port ${PORT}       => use Render's $PORT
#    --pass-environment   => forward env vars (AZURE_DEVOPS_PAT, etc.) to the stdio server
#    npx -y @azure-devops/mcp => run the official Microsoft Azure DevOps MCP stdio server
CMD ["sh", "-c", "mcp-proxy --host=0.0.0.0 --port=${PORT} --pass-environment -- npx -y @azure-devops/mcp"]
