FROM node:18-alpine

# Set working directory
WORKDIR /app

# Install dependencies first (leveraging Docker cache)
COPY package*.json ./
RUN npm install

# Copy the rest of the app code
COPY . .

# Expose app port
EXPOSE 3000

# Start the app
CMD ["npm", "start"]
