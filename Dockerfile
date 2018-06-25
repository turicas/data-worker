FROM gliderlabs/herokuish
RUN mkdir -p /app
ADD . /app
WORKDIR /app
RUN /build
VOLUME /app/data
ENTRYPOINT ["/exec"]
CMD ["/app/run.sh"]
