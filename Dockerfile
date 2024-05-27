FROM ruby:3.1.0
ARG ROOT="/cat-hotwire-demo"
ENV LANG=C.UTF-8
ENV TZ=Asia/Tokyo

WORKDIR ${ROOT}

RUN apt-get update; \
  apt-get install -y --no-install-recommends \
	postgresql-client

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update && apt-get install -y yarn

COPY Gemfile ${ROOT}
COPY Gemfile.lock ${ROOT}
RUN gem install bundler
RUN bundle install --jobs 4 --path vendor/bundle

COPY package.json ${ROOT}/package.json
COPY yarn.lock ${ROOT}/yarn.lock
RUN yarn install

# RUN yarn global add sass esbuild

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Configure the main process to run when running the image
CMD ["bin/dev"]
