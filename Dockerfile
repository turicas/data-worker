FROM gliderlabs/herokuish

RUN mkdir -p /app
WORKDIR /app

ADD . /app
RUN /build

ENTRYPOINT ["/exec"]
CMD ["/app/run.sh"]
