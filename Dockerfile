FROM alpine/git AS build_git
RUN git clone https://github.com/pa11y/pa11y-webservice.git /app

FROM node:21-slim AS build_node
COPY --from=build_git /app /app
WORKDIR /app
RUN cd /app; \
    npm install;

FROM node:21-slim
COPY --from=build_node /app /app
WORKDIR /app

RUN apt-get update \
    && apt-get install -y wget gnupg \
    && wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' \
    && apt-get update \
    && apt-get install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-kacst fonts-freefont-ttf libxss1 \
    --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

RUN cd /app; \
    . /etc/os-release; \
    echo "${NAME} ${VERSION_ID}" > /version.txt; \
    echo "node $(node --version)" >> /version.txt; \
    echo "pa11y-webservice $(cat /app/.git/refs/heads/master)" >> /version.txt; \
    cp /app/config/development.sample.json /app/config/development.json; \
    cp /app/config/production.sample.json /app/config/production.json;

CMD ["node", "index.js"]
