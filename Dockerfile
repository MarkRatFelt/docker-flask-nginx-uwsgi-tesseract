FROM ubuntu:16.04

MAINTAINER Dockerfiles

# Install required packages and remove the apt packages cache when done.
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y \
    autoconf \
    autoconf-archive \
    automake \
    build-essential\
	git \
	libcv-dev \
	libjpeg-dev \
	libjpeg8-dev \
	libleptonica-dev \
	libopencv-dev \
	libpng12-dev \
	libtesseract-dev \
	libtiff5-dev \
	libtool \
	pkg-config \
	python3 \
	python3-dev \
	python3-setuptools \
	python3-pip \
	nginx \
	supervisor \
	sqlite3 \
	tesseract-ocr \
	zlib1g-dev \
	curl wget locales && \
	pip3 install -U pip setuptools && \
   rm -rf /var/lib/apt/lists/*

# Ensure that we always use UTF-8 and with German locale
RUN locale-gen de_DE.UTF-8

COPY ./default_locale /etc/default/locale
RUN chmod 0755 /etc/default/locale

ENV PYTHONIOENCODING=utf-8
ENV LC_ALL=de_DE.UTF-8
ENV LANG=de_DE.UTF-8
ENV LANGUAGE=de_DE.UTF-8

# install leptonica
RUN curl http://www.leptonica.org/source/leptonica-1.74.4.tar.gz -o leptonica-1.74.4.tar.gz && \
	tar -zxvf leptonica-1.74.4.tar.gz && \
	cd leptonica-1.74.4 && ./configure && make && make install && \
	cd .. && rm -rf leptonica*

# install tesseract
RUN git clone --depth 1 https://github.com/tesseract-ocr/tesseract.git && \
	cd tesseract && \
	./autogen.sh && \
	./configure && \
	LDFLAGS="-L/usr/local/lib" CFLAGS="-I/usr/local/include" make && \
	make install && \
	ldconfig && \
	cd .. && rm -rf tesseract

# Get basic traineddata
RUN curl -LO https://github.com/tesseract-ocr/tessdata/raw/master/deu.traineddata && \
	mv deu.traineddata /usr/local/share/tessdata/

# install uwsgi now because it takes a little while
RUN pip3 install uwsgi

# setup all the configfiles
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
COPY nginx_app.conf /etc/nginx/sites-available/default
COPY supervisor_app.conf /etc/supervisor/conf.d/


# copy over our requirements.txt file
COPY requirements.txt /home/docker/code/

# upgrade pip and install required python packages
RUN pip3 --no-cache-dir install -U pip
RUN pip3 --no-cache-dir install -r /home/docker/code/requirements.txt

# add (the rest of) our code
COPY ./app /home/docker/code/

EXPOSE 80
CMD ["supervisord"]
