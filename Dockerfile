FROM alpine/git AS build_git
RUN git clone https://github.com/pa11y/pa11y-webservice.git /app

FROM node:lts-alpine AS build_node
COPY --from=build_git /app /app
WORKDIR /app
RUN cd /app; \
    npm install;

FROM node:lts-alpine
COPY --from=build_node /app /app
WORKDIR /app
RUN cd /app; \
    . /etc/os-release; \
    echo "${NAME} ${VERSION_ID}" > /version.txt; \
    echo "node $(node --version)" >> /version.txt; \
    echo "pa11y-webservice $(cat /app/.git/refs/heads/master)" >> /version.txt;
CMD ["node", "index.js"]
