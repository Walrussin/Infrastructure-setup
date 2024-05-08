# Use an official Node runtime as a parent image
FROM node AS builder

# Set the working directory in the container
WORKDIR /app

# Copy package.json and package-lock.json to the working directory
COPY package*.json ./

# Install Angular CLI globally
RUN npm install -g @angular/cli

# Install dependencies
RUN npm install

# Copy the rest of the application code to the working directory
COPY . .

# Build the Angular app for production with the ng build command
RUN ng build

# Use a smaller base image for serving the Angular app
FROM nginx:alpine

# Copy the default Nginx configuration file
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the built Angular app from the builder stage to the nginx server directory
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80 to the outside world
EXPOSE 80

# Command to run the Angular app using nginx
CMD ["nginx", "-g", "daemon off;"]