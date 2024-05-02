# Set the default value for the MEDIA_WIKI_VERSION argument
ARG MEDIA_WIKI_VERSION=1.41

##########################################################
#                     The base image                     #
##########################################################
# Use the specified MediaWiki version as the base image
FROM mediawiki:${MEDIA_WIKI_VERSION} AS mediawiki


##########################################################
#    Create a build stage for MediaWiki dependencies     #
##########################################################
# Use the base MediaWiki image as the starting point for the build stage
FROM mediawiki AS mediawiki_build_stage

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin -- --filename=composer

# Copy maintenance scripts
COPY ./docker/mediawiki/scripts /usr/local/bin/maintenance
RUN chmod +x /usr/local/bin/maintenance/*
RUN mv /usr/local/bin/maintenance/* /usr/local/bin \
    && rmdir /usr/local/bin/maintenance

# Set Composer environment variables
ENV COMPOSER_HOME /composer
ENV PATH $PATH:/composer/vendor/bin
ENV COMPOSER_ALLOW_SUPERUSER 1

# Set the working directory
WORKDIR /var/www/html

# Clone UniversalLanguageSelector extension
RUN git clone --depth=1 --branch 2024.01 https://gerrit.wikimedia.org/r/mediawiki/extensions/UniversalLanguageSelector ./extensions/UniversalLanguageSelector

# Set the INSTANCE_BUILD argument
ARG INSTANCE_BUILD=matsin
ARG EXTENSION_SOURCE=/extensions

# Copy common and instance-specific extensions
COPY ./extensions/common ${EXTENSION_SOURCE}
COPY ./extensions/${INSTANCE_BUILD} ${EXTENSION_SOURCE}

# Install extensions
RUN yarsin install_extensions ${EXTENSION_SOURCE}

# Copy Composer configuration files
COPY ./extensions/common/composer.local.json ./composer.local.json
COPY ./extensions/${INSTANCE_BUILD}/composer.local.json ./composer.${INSTANCE_BUILD}.json

# Update Composer dependencies
RUN composer update --no-dev


##########################################################
#          Create a run stage for Prosin wiki            #
##########################################################
# Create a new image stage named 'matsin' based on the mediawiki image
FROM mediawiki AS mediawiki_run_stage

# Copy maintenance scripts
COPY ./docker/mediawiki/scripts /usr/local/bin/maintenance
RUN chmod +x /usr/local/bin/maintenance/*
RUN mv /usr/local/bin/maintenance/* /usr/local/bin \
    && rmdir /usr/local/bin/maintenance

# Copy the WikiMedia files from the mediawiki_build_stage to /var/www/html
COPY --chown=www-data:www-data --from=mediawiki_build_stage /var/www/html /var/www/html

# Expose port 80 for the container
EXPOSE 80
