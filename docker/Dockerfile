FROM nginx:latest

# maintainer branch commitId datetime
ARG branch
ARG commitId
ARG datetime
LABEL maintainer="ian.chen@storicard.com" branch=${branch} commitId=${commitId} datetime=${datetime}

# change nginx.conf and dist file
RUN rm /etc/nginx/conf.d/default.conf
ADD docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY dist/ /usr/share/nginx/html/