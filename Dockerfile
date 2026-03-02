# Use the official Swift image that 
# already ships with swiftc and the iOS 
# SDK
FROM swift:5.10
# Install clang, zip, and other 
# utilities needed for linking & 
# packaging
RUN apt-get update && apt-get install -y 
\
    clang \ zip \ unzip \ 
    libncurses5-dev \ libncursesw5-dev \ 
    libssl-dev \ libcurl4-openssl-dev \ 
    libsqlite3-dev \ && rm -rf 
    /var/lib/apt/lists/*
# Set the working directory inside the 
# container
WORKDIR /src
# Copy the source files and the build 
# script into the container
COPY src/ /src/
# Make sure the build script is 
# executable
RUN chmod +x /src/build.sh
# By default run the build script when 
# the container starts
ENTRYPOINT ["/src/build.sh"]
