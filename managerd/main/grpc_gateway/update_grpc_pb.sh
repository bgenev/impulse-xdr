#!/bin/bash


#source /opt/impulse/aux_server/aux-venv/bin/activate
cd /opt/impulse/managerd/main/grpc_gateway
python3 -m grpc_tools.protoc -I grpc_pb=./protos --python_out=./ --grpc_python_out=./ protos/grpc_gateway.proto

sed -i '/from grpc_pb import grpc_gateway_pb2/c\from . import grpc_gateway_pb2 as grpc__pb_dot_grpc__gateway__pb2' grpc_pb/grpc_gateway_pb2_grpc.py
