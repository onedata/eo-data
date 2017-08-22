FROM busybox

MAINTAINER Michal Orzechowski <orzechowski.michal@gmail.com>

ARG PATHS_FILE
ARG NUMBER_OF_FILES
LABEL number-of-files=${NUMBER_OF_FILES}

ENV NUMBER_OF_FILES=${NUMBER_OF_FILES}

COPY ${PATHS_FILE} /paths
RUN while read file ; do mkdir -p $(dirname $file) ; touch $file ; echo "$file" > $file  ; done < paths

