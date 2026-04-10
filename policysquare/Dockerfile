# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY . .
# Get flutter dependencies.
RUN flutter pub get
# Build web app
RUN flutter build web --release

# Run stage
FROM nginx:alpine
# Copy the compiled web assets to Nginx's default HTML folder
COPY --from=build /app/build/web /usr/share/nginx/html
# We will override the default nginx.conf with our own in docker-compose
EXPOSE 80
EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
