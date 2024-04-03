# docker-otrs
Docker OTRS


## Build
```
docker build --no-cache -t jniltinho/otrs-server .
```

## Run
```
docker run -d --name otrs-server -p 8080:80 jniltinho/otrs-server
```
