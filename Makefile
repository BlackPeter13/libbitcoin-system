CXXFLAGS= -std=c++0x -Wall -pedantic -pthread -Wextra -fstack-protector-all -ggdb -fPIC
INCLUDES= -Iinclude/ -Iusr/include/
LIBS= -Lusr/lib -lcppdb -lcrypto -lboost_thread -lboost_system -ldl -lpq
BASE_MODULES= \
	network.o  \
	dialect.o  \
	channel.o \
	serializer.o \
	logger.o \
	kernel.o \
	sha256.o \
	types.o \
	script.o \
	ripemd.o \
	postgresql_storage.o \
	block.o \
    elliptic_curve_key.o \
	transaction.o \
	error.o \
	threaded_service.o \
	postgresql_blockchain.o \
    validate.o \
	big_number.o \
	clock.o \
	constants.o
MODULES=$(addprefix obj/, $(BASE_MODULES))
#OBJECTS=$(addprefix obj/, $(notdir $(SOURCES:.cpp=.o)))
LIBBITCOIN=-Llib -lbitcoin

#%.o: %.cpp
#	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $(INCLUDES) -c $(input) $(output)

#$(OBJECTS): $(SOURCES)
#	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

default: libbitcoin.so

lib/libbitcoin.so: $(MODULES)
	$(CXX) -shared $(MODULES) -o lib/libbitcoin.so

lib/libbitcoin.a: $(MODULES)
	ar crf lib/libbitcoin.a $(MODULES)

libbitcoin: lib/libbitcoin.so lib/libbitcoin.a

obj/poller.o: examples/poller.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o obj/poller.o examples/poller.cpp

bin/examples/poller: libbitcoin obj/poller.o
	$(CXX) -o bin/examples/poller obj/poller.o $(LIBBITCOIN) $(LIBS)

bin/tests/nettest: libbitcoin obj/nettest.o
	$(CXX) -o bin/tests/nettest obj/nettest.o $(LIBBITCOIN) $(LIBS)

net: bin/tests/nettest

bin/tests/blockchain: libbitcoin.so obj/blockchain.o
	$(CXX) -o bin/tests/blockchain obj/blockchain.o $(LIBBITCOIN) $(LIBS)


block: src/block.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/ripemd.o: src/util/ripemd.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

sha256: src/util/sha256.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/logger.o: src/util/logger.cpp include/bitcoin/util/logger.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

transaction: src/transaction.cpp include/bitcoin/transaction.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

script: src/script.cpp include/bitcoin/script.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/block.o: src/block.cpp include/bitcoin/block.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/network.o: src/network/network.cpp include/bitcoin/network/network.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/dialect.o: src/dialect.cpp include/bitcoin/dialect.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/channel.o: src/network/channel.cpp src/network/channel.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/sha256.o: src/util/sha256.cpp include/bitcoin/util/sha256.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/kernel.o: src/kernel.cpp include/bitcoin/kernel.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/error.o: src/error.cpp include/bitcoin/error.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/serializer.o: src/util/serializer.cpp include/bitcoin/util/serializer.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

libbitcoin.a: obj/serializer.o obj/error.o

obj/nettest.o: tests/net.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/postgresql_storage.o: src/storage/postgresql_storage.cpp include/bitcoin/storage/postgresql_storage.hpp 
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/elliptic_curve_key.o: src/util/elliptic_curve_key.cpp include/bitcoin/util/elliptic_curve_key.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/validate.o: src/validate.cpp include/bitcoin/validate.hpp 
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<


obj/threaded_service.o: src/util/threaded_service.cpp include/bitcoin/util/threaded_service.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/types.o: src/types.cpp include/bitcoin/types.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/gengen.o: tests/gengen.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

bin/tests/gengen: obj/gengen.o obj/logger.o obj/sha256.o  obj/types.o obj/serializer.o obj/types.o
	$(CXX) -o bin/tests/gengen obj/gengen.o obj/logger.o obj/sha256.o  obj/types.o obj/serializer.o $(LIBS)

gengen: bin/tests/gengen

obj/script.o: src/script.cpp include/bitcoin/script.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/script-test.o: tests/script-test.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

bin/tests/script-test: obj/script-test.o obj/script.o obj/logger.o obj/sha256.o obj/ripemd.o obj/types.o obj/postgresql_storage.o obj/transaction.o obj/block.o obj/serializer.o obj/elliptic_curve_key.o obj/error.o obj/postgresql_blockchain.o obj/threaded_service.o
	$(CXX) -o bin/tests/script-test obj/script-test.o obj/script.o obj/logger.o obj/sha256.o obj/ripemd.o obj/types.o obj/postgresql_storage.o obj/transaction.o obj/block.o obj/serializer.o obj/elliptic_curve_key.o obj/error.o obj/postgresql_blockchain.o obj/threaded_service.o $(LIBS)

obj/postbind.o: tests/postbind.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

bin/tests/postbind: obj/postbind.o
	$(CXX) -o bin/tests/postbind obj/postbind.o $(LIBS)

postbind: bin/tests/postbind

script-test: bin/tests/script-test

obj/psql.o: tests/psql.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

bin/tests/psql: obj/postgresql_storage.o obj/psql.o obj/logger.o obj/script.o obj/ripemd.o obj/block.o obj/serializer.o obj/sha256.o obj/types.o obj/transaction.o obj/error.o obj/elliptic_curve_key.o obj/threaded_service.o
	$(CXX) -o bin/tests/psql obj/psql.o obj/postgresql_storage.o obj/logger.o obj/script.o obj/ripemd.o obj/block.o obj/serializer.o obj/sha256.o obj/types.o obj/transaction.o obj/error.o obj/elliptic_curve_key.o obj/threaded_service.o $(LIBS)

psql: bin/tests/psql

obj/types-test.o: tests/types-test.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

bin/tests/types-test: obj/types.o obj/types-test.o
	$(CXX) -o bin/tests/types-test obj/types.o obj/types-test.o $(LIBS)

types-test: bin/tests/types-test

obj/merkle.o: tests/merkle.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

bin/tests/merkle: obj/merkle.o obj/postgresql_storage.o obj/sha256.o obj/script.o obj/logger.o obj/ripemd.o obj/types.o obj/block.o obj/serializer.o obj/transaction.o obj/elliptic_curve_key.o obj/error.o obj/threaded_service.o obj/postgresql_blockchain.o obj/validate.o obj/big_number.o obj/dialect.o obj/constants.o obj/clock.o 
	$(CXX) -o bin/tests/merkle obj/merkle.o obj/postgresql_storage.o obj/sha256.o obj/script.o obj/logger.o obj/ripemd.o obj/types.o obj/block.o obj/serializer.o obj/transaction.o obj/elliptic_curve_key.o obj/error.o obj/threaded_service.o  obj/postgresql_blockchain.o obj/validate.o obj/big_number.o obj/dialect.o obj/constants.o obj/clock.o $(LIBS)

merkle: bin/tests/merkle

obj/transaction.o: src/transaction.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/tx-hash.o: tests/tx-hash.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

bin/tests/tx-hash: obj/tx-hash.o obj/transaction.o obj/sha256.o obj/script.o obj/serializer.o obj/logger.o obj/types.o obj/ripemd.o obj/elliptic_curve_key.o
	$(CXX) -o bin/tests/tx-hash obj/tx-hash.o obj/transaction.o obj/sha256.o obj/script.o obj/serializer.o obj/logger.o obj/types.o obj/ripemd.o obj/elliptic_curve_key.o $(LIBS)

tx-hash: bin/tests/tx-hash

obj/block-hash.o: tests/block-hash.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

bin/tests/block-hash: obj/block-hash.o obj/block.o obj/postgresql_storage.o obj/sha256.o obj/script.o obj/logger.o obj/ripemd.o obj/types.o obj/serializer.o obj/transaction.o obj/elliptic_curve_key.o obj/error.o
	$(CXX) -o bin/tests/block-hash obj/block-hash.o obj/block.o obj/postgresql_storage.o obj/sha256.o obj/script.o obj/logger.o obj/ripemd.o obj/types.o obj/serializer.o obj/transaction.o obj/elliptic_curve_key.o obj/error.o $(LIBS)

block-hash: bin/tests/block-hash

obj/ec-key.o: tests/ec-key.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

bin/tests/ec-key: obj/ec-key.o obj/serializer.o obj/elliptic_curve_key.o obj/types.o obj/sha256.o obj/logger.o
	$(CXX) -o bin/tests/ec-key obj/ec-key.o obj/serializer.o obj/elliptic_curve_key.o obj/types.o obj/sha256.o obj/logger.o $(LIBS)

ec-key: bin/tests/ec-key

obj/clock.o: src/util/clock.cpp include/bitcoin/util/clock.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/constants.o: src/constants.cpp include/bitcoin/constants.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/validate-block.o: tests/validate-block.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

bin/tests/validate-block: obj/validate-block.o obj/postgresql_storage.o obj/logger.o obj/serializer.o obj/elliptic_curve_key.o obj/sha256.o obj/ripemd.o obj/types.o obj/block.o obj/error.o obj/validate.o obj/dialect.o obj/constants.o obj/big_number.o obj/clock.o
	$(CXX) -o bin/tests/validate-block obj/validate-block.o obj/postgresql_storage.o obj/transaction.o obj/script.o obj/logger.o obj/serializer.o obj/elliptic_curve_key.o obj/sha256.o obj/ripemd.o obj/types.o obj/block.o obj/error.o obj/validate.o obj/threaded_service.o obj/dialect.o obj/constants.o obj/big_number.o obj/clock.o $(LIBS)

validate-block: bin/tests/validate-block

obj/big_number.o: src/util/big_number.cpp include/bitcoin/util/big_number.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/big-number-test.o: tests/big-number-test.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

bin/tests/big-number-test: obj/big-number-test.o obj/big_number.o obj/logger.o obj/constants.o obj/types.o
	$(CXX) -o bin/tests/big-number-test obj/big-number-test.o obj/big_number.o obj/logger.o obj/constants.o obj/types.o $(LIBS)

big-number-test: bin/tests/big-number-test


poller: bin/examples/poller

obj/postgresql_blockchain.o: src/storage/postgresql_blockchain.cpp src/storage/postgresql_blockchain.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

obj/blockchain.o: tests/blockchain.cpp
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c -o $@ $<

blockchain: bin/tests/blockchain

