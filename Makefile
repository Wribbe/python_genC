DIR_ROOT := genC

DIR_BIN := ${DIR_ROOT}/bin
DIR_SRC := ${DIR_ROOT}/src
DIR_TMP := ${DIR_ROOT}/tmp
DIR_LIB := ${DIR_ROOT}/lib

BINS := $(foreach file,$(notdir $(wildcard ${DIR_SRC}/*.py)),${DIR_BIN}/${file:%.py=%})

.PRECIOUS: ${DIR_TMP}/%.c

DIR_GLAD := glad

CC := gcc

CFLAGS += --std=c11 -Wall -Werror
CFLAGS += $(shell pkg-config --cflags glfw3)


INCLUDES := -I${DIR_LIB}
INCLUDES += $(shell pkg-config --libs --static glfw3 | tr -s ' ' '\n' | sort -u | tr -s '\n' ' ')


all : ${BINS}


${DIR_TMP}/%.c : ${DIR_SRC}/%.py | ${DIR_TMP}
	python $^ > $@


${DIR_LIB}/glad/glad.c ${DIR_LIB}/glad/glad.h : ${DIR_GLAD}
	cd ${DIR_GLAD}; python -m glad --generator=c --out-path .
	[ -d ${DIR_LIB}/glad ] || mkdir ${DIR_LIB}/glad
	mv ${DIR_GLAD}/src/glad.c ${DIR_LIB}/glad/glad.c
	mv ${DIR_GLAD}/include/glad/glad.h ${DIR_LIB}/glad/glad.h
	rm -rf ${DIR_GLAD}


${DIR_BIN}/% : ${DIR_TMP}/%.c ${DIR_LIB}/glad/glad.c | ${DIR_BIN}
	${CC} ${CFLAGS} $^ -o $@ ${INCLUDES}


${DIR_TMP} ${DIR_BIN} :
	@mkdir $@

${DIR_GLAD} :
	git clone https://github.com/Dav1dde/glad.git

clean :
	rm -rf ${DIR_TMP} ${DIR_BIN} ${DIR_GLAD} ${DIR_LIB}/glad
