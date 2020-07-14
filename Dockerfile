FROM jordaan0/caesar_base

# Variables
ENV SOURCE_BASE_DIR /scratch
ENV INSTALL_BASE_DIR /opt

ENV SOURCE_CAESAR_DIR ${SOURCE_BASE_DIR}/caesar
ENV INSTALL_CAESAR_DIR ${INSTALL_BASE_DIR}/caesar

# build container
RUN cd $SOURCE_BASE_DIR &&\
    git clone https://github.com/SKA-INAF/caesar &&\
    cd $SOURCE_CAESAR_DIR && git checkout devel

RUN mkdir $SOURCE_CAESAR_DIR/build_caesar && \
    mkdir $INSTALL_CAESAR_DIR && \
    mkdir $INSTALL_CAESAR_DIR/include

ENV CC mpicc
ENV CXX mpic++
ENV PATH $CMAKE_INSTALL_DIR/bin:$PATH

RUN R -e "install.packages('RInside',dependencies=TRUE, repos='http://cran.rstudio.com/')"
ENV LD_LIBRARY_PATH /usr/local/lib/R/site-library/RInside/lib:$LD_LIBRARY_PATH

RUN cd $SOURCE_CAESAR_DIR/build_caesar && \
    ${CMAKE_RECENT} \
    -D CMAKE_INSTALL_PREFIX=$INSTALL_CAESAR_DIR \
    -D CMAKE_CXX_FLAGS="-O -Wall -fPIC -std=gnu++11" \
    -D BUILD_DOC=OFF \
    -D ENABLE_VTK=OFF \
    -D ENABLE_TEST=OFF \
    -D BUILD_WITH_OPENMP=OFF \
    -D MPI_ENABLED=ON \
    -D ENABLE_MPI=ON \
    -D BUILD_APPS=ON \
    -D ENABLE_R=ON \
    $SOURCE_CAESAR_DIR && \
    make && \
    make install

ENV LD_LIBRARY_PATH $INSTALL_CAESAR_DIR/lib:$LD_LIBRARY_PATH
ENV PATH $INSTALL_CAESAR_DIR/bin:$INSTALL_CAESAR_DIR/scripts:$PATH
ENV CAESAR_DIR /opt/caesar

RUN echo "export LD_LIBRARY_PATH=/opt/caesar/lib:/usr/local/lib/R/site-library/RInside/lib:/opt/root/lib:/lib::/opt/OpenCV/lib:/opt/jsoncpp/lib:/opt/jsoncpp/lib" >> /root/.bashrc && \
    echo "export LD_LIBRARY_PATH=/opt/caesar/lib:/usr/local/lib/R/site-library/RInside/lib:/opt/root/lib:/lib::/opt/OpenCV/lib:/opt/jsoncpp/lib:/opt/jsoncpp/lib" >> /home/openmpi/.bashrc

