# Generated by the gRPC Python protocol compiler plugin. DO NOT EDIT!
"""Client and server classes corresponding to protobuf-defined services."""
import grpc

from . import grpc_gateway_pb2 as grpc__pb_dot_grpc__gateway__pb2


class GrpcGatewayStub(object):
    """Missing associated documentation comment in .proto file."""

    def __init__(self, channel):
        """Constructor.

        Args:
            channel: A grpc.Channel.
        """
        self.RunOSqueryOnAgent = channel.unary_unary(
                '/grpc_gateway.GrpcGateway/RunOSqueryOnAgent',
                request_serializer=grpc__pb_dot_grpc__gateway__pb2.RunOSqueryOnAgentRequest.SerializeToString,
                response_deserializer=grpc__pb_dot_grpc__gateway__pb2.RunOSqueryOnAgentResponse.FromString,
                )
        self.FirewallManagementState = channel.unary_unary(
                '/grpc_gateway.GrpcGateway/FirewallManagementState',
                request_serializer=grpc__pb_dot_grpc__gateway__pb2.FirewallManagementStateRequest.SerializeToString,
                response_deserializer=grpc__pb_dot_grpc__gateway__pb2.FirewallManagementStateResponse.FromString,
                )
        self.CheckAgentStatus = channel.unary_unary(
                '/grpc_gateway.GrpcGateway/CheckAgentStatus',
                request_serializer=grpc__pb_dot_grpc__gateway__pb2.CheckAgentStatusRequest.SerializeToString,
                response_deserializer=grpc__pb_dot_grpc__gateway__pb2.CheckAgentStatusResponse.FromString,
                )
        self.DeployPackOnAgent = channel.unary_unary(
                '/grpc_gateway.GrpcGateway/DeployPackOnAgent',
                request_serializer=grpc__pb_dot_grpc__gateway__pb2.DeployPackOnAgentRequest.SerializeToString,
                response_deserializer=grpc__pb_dot_grpc__gateway__pb2.DeployPackOnAgentResponse.FromString,
                )
        self.CoreOsqPackUpdate = channel.unary_unary(
                '/grpc_gateway.GrpcGateway/CoreOsqPackUpdate',
                request_serializer=grpc__pb_dot_grpc__gateway__pb2.CoreOsqPackUpdateRequest.SerializeToString,
                response_deserializer=grpc__pb_dot_grpc__gateway__pb2.CoreOsqPackUpdateResponse.FromString,
                )
        self.DeletePackOnAgent = channel.unary_unary(
                '/grpc_gateway.GrpcGateway/DeletePackOnAgent',
                request_serializer=grpc__pb_dot_grpc__gateway__pb2.DeletePackOnAgentRequest.SerializeToString,
                response_deserializer=grpc__pb_dot_grpc__gateway__pb2.DeletePackOnAgentResponse.FromString,
                )
        self.TakeActionAgent = channel.unary_unary(
                '/grpc_gateway.GrpcGateway/TakeActionAgent',
                request_serializer=grpc__pb_dot_grpc__gateway__pb2.TakeActionAgentRequest.SerializeToString,
                response_deserializer=grpc__pb_dot_grpc__gateway__pb2.TakeActionAgentResponse.FromString,
                )
        self.CheckCanTakeActionAgent = channel.unary_unary(
                '/grpc_gateway.GrpcGateway/CheckCanTakeActionAgent',
                request_serializer=grpc__pb_dot_grpc__gateway__pb2.CheckCanTakeActionAgentRequest.SerializeToString,
                response_deserializer=grpc__pb_dot_grpc__gateway__pb2.CheckCanTakeActionAgentResponse.FromString,
                )
        self.ReceiveScaScanReq = channel.unary_unary(
                '/grpc_gateway.GrpcGateway/ReceiveScaScanReq',
                request_serializer=grpc__pb_dot_grpc__gateway__pb2.ReceiveScaScanReqRequest.SerializeToString,
                response_deserializer=grpc__pb_dot_grpc__gateway__pb2.ReceiveScaScanReqResponse.FromString,
                )
        self.AgentSystemPosture = channel.unary_unary(
                '/grpc_gateway.GrpcGateway/AgentSystemPosture',
                request_serializer=grpc__pb_dot_grpc__gateway__pb2.AgentSystemPostureRequest.SerializeToString,
                response_deserializer=grpc__pb_dot_grpc__gateway__pb2.AgentSystemPostureResponse.FromString,
                )
        self.RunPolicyPackQueries = channel.unary_unary(
                '/grpc_gateway.GrpcGateway/RunPolicyPackQueries',
                request_serializer=grpc__pb_dot_grpc__gateway__pb2.RunPolicyPackQueriesRequest.SerializeToString,
                response_deserializer=grpc__pb_dot_grpc__gateway__pb2.RunPolicyPackQueriesResponse.FromString,
                )
        self.GetServiceData = channel.unary_unary(
                '/grpc_gateway.GrpcGateway/GetServiceData',
                request_serializer=grpc__pb_dot_grpc__gateway__pb2.GetServiceDataRequest.SerializeToString,
                response_deserializer=grpc__pb_dot_grpc__gateway__pb2.GetServiceDataResponse.FromString,
                )
        self.SuricataCustomRulesetSync = channel.unary_unary(
                '/grpc_gateway.GrpcGateway/SuricataCustomRulesetSync',
                request_serializer=grpc__pb_dot_grpc__gateway__pb2.SuricataCustomRulesetSyncRequest.SerializeToString,
                response_deserializer=grpc__pb_dot_grpc__gateway__pb2.SuricataCustomRulesetSyncResponse.FromString,
                )


class GrpcGatewayServicer(object):
    """Missing associated documentation comment in .proto file."""

    def RunOSqueryOnAgent(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def FirewallManagementState(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def CheckAgentStatus(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def DeployPackOnAgent(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def CoreOsqPackUpdate(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def DeletePackOnAgent(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def TakeActionAgent(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def CheckCanTakeActionAgent(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def ReceiveScaScanReq(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def AgentSystemPosture(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def RunPolicyPackQueries(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def GetServiceData(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')

    def SuricataCustomRulesetSync(self, request, context):
        """Missing associated documentation comment in .proto file."""
        context.set_code(grpc.StatusCode.UNIMPLEMENTED)
        context.set_details('Method not implemented!')
        raise NotImplementedError('Method not implemented!')


def add_GrpcGatewayServicer_to_server(servicer, server):
    rpc_method_handlers = {
            'RunOSqueryOnAgent': grpc.unary_unary_rpc_method_handler(
                    servicer.RunOSqueryOnAgent,
                    request_deserializer=grpc__pb_dot_grpc__gateway__pb2.RunOSqueryOnAgentRequest.FromString,
                    response_serializer=grpc__pb_dot_grpc__gateway__pb2.RunOSqueryOnAgentResponse.SerializeToString,
            ),
            'FirewallManagementState': grpc.unary_unary_rpc_method_handler(
                    servicer.FirewallManagementState,
                    request_deserializer=grpc__pb_dot_grpc__gateway__pb2.FirewallManagementStateRequest.FromString,
                    response_serializer=grpc__pb_dot_grpc__gateway__pb2.FirewallManagementStateResponse.SerializeToString,
            ),
            'CheckAgentStatus': grpc.unary_unary_rpc_method_handler(
                    servicer.CheckAgentStatus,
                    request_deserializer=grpc__pb_dot_grpc__gateway__pb2.CheckAgentStatusRequest.FromString,
                    response_serializer=grpc__pb_dot_grpc__gateway__pb2.CheckAgentStatusResponse.SerializeToString,
            ),
            'DeployPackOnAgent': grpc.unary_unary_rpc_method_handler(
                    servicer.DeployPackOnAgent,
                    request_deserializer=grpc__pb_dot_grpc__gateway__pb2.DeployPackOnAgentRequest.FromString,
                    response_serializer=grpc__pb_dot_grpc__gateway__pb2.DeployPackOnAgentResponse.SerializeToString,
            ),
            'CoreOsqPackUpdate': grpc.unary_unary_rpc_method_handler(
                    servicer.CoreOsqPackUpdate,
                    request_deserializer=grpc__pb_dot_grpc__gateway__pb2.CoreOsqPackUpdateRequest.FromString,
                    response_serializer=grpc__pb_dot_grpc__gateway__pb2.CoreOsqPackUpdateResponse.SerializeToString,
            ),
            'DeletePackOnAgent': grpc.unary_unary_rpc_method_handler(
                    servicer.DeletePackOnAgent,
                    request_deserializer=grpc__pb_dot_grpc__gateway__pb2.DeletePackOnAgentRequest.FromString,
                    response_serializer=grpc__pb_dot_grpc__gateway__pb2.DeletePackOnAgentResponse.SerializeToString,
            ),
            'TakeActionAgent': grpc.unary_unary_rpc_method_handler(
                    servicer.TakeActionAgent,
                    request_deserializer=grpc__pb_dot_grpc__gateway__pb2.TakeActionAgentRequest.FromString,
                    response_serializer=grpc__pb_dot_grpc__gateway__pb2.TakeActionAgentResponse.SerializeToString,
            ),
            'CheckCanTakeActionAgent': grpc.unary_unary_rpc_method_handler(
                    servicer.CheckCanTakeActionAgent,
                    request_deserializer=grpc__pb_dot_grpc__gateway__pb2.CheckCanTakeActionAgentRequest.FromString,
                    response_serializer=grpc__pb_dot_grpc__gateway__pb2.CheckCanTakeActionAgentResponse.SerializeToString,
            ),
            'ReceiveScaScanReq': grpc.unary_unary_rpc_method_handler(
                    servicer.ReceiveScaScanReq,
                    request_deserializer=grpc__pb_dot_grpc__gateway__pb2.ReceiveScaScanReqRequest.FromString,
                    response_serializer=grpc__pb_dot_grpc__gateway__pb2.ReceiveScaScanReqResponse.SerializeToString,
            ),
            'AgentSystemPosture': grpc.unary_unary_rpc_method_handler(
                    servicer.AgentSystemPosture,
                    request_deserializer=grpc__pb_dot_grpc__gateway__pb2.AgentSystemPostureRequest.FromString,
                    response_serializer=grpc__pb_dot_grpc__gateway__pb2.AgentSystemPostureResponse.SerializeToString,
            ),
            'RunPolicyPackQueries': grpc.unary_unary_rpc_method_handler(
                    servicer.RunPolicyPackQueries,
                    request_deserializer=grpc__pb_dot_grpc__gateway__pb2.RunPolicyPackQueriesRequest.FromString,
                    response_serializer=grpc__pb_dot_grpc__gateway__pb2.RunPolicyPackQueriesResponse.SerializeToString,
            ),
            'GetServiceData': grpc.unary_unary_rpc_method_handler(
                    servicer.GetServiceData,
                    request_deserializer=grpc__pb_dot_grpc__gateway__pb2.GetServiceDataRequest.FromString,
                    response_serializer=grpc__pb_dot_grpc__gateway__pb2.GetServiceDataResponse.SerializeToString,
            ),
            'SuricataCustomRulesetSync': grpc.unary_unary_rpc_method_handler(
                    servicer.SuricataCustomRulesetSync,
                    request_deserializer=grpc__pb_dot_grpc__gateway__pb2.SuricataCustomRulesetSyncRequest.FromString,
                    response_serializer=grpc__pb_dot_grpc__gateway__pb2.SuricataCustomRulesetSyncResponse.SerializeToString,
            ),
    }
    generic_handler = grpc.method_handlers_generic_handler(
            'grpc_gateway.GrpcGateway', rpc_method_handlers)
    server.add_generic_rpc_handlers((generic_handler,))


 # This class is part of an EXPERIMENTAL API.
class GrpcGateway(object):
    """Missing associated documentation comment in .proto file."""

    @staticmethod
    def RunOSqueryOnAgent(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/grpc_gateway.GrpcGateway/RunOSqueryOnAgent',
            grpc__pb_dot_grpc__gateway__pb2.RunOSqueryOnAgentRequest.SerializeToString,
            grpc__pb_dot_grpc__gateway__pb2.RunOSqueryOnAgentResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def FirewallManagementState(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/grpc_gateway.GrpcGateway/FirewallManagementState',
            grpc__pb_dot_grpc__gateway__pb2.FirewallManagementStateRequest.SerializeToString,
            grpc__pb_dot_grpc__gateway__pb2.FirewallManagementStateResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def CheckAgentStatus(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/grpc_gateway.GrpcGateway/CheckAgentStatus',
            grpc__pb_dot_grpc__gateway__pb2.CheckAgentStatusRequest.SerializeToString,
            grpc__pb_dot_grpc__gateway__pb2.CheckAgentStatusResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def DeployPackOnAgent(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/grpc_gateway.GrpcGateway/DeployPackOnAgent',
            grpc__pb_dot_grpc__gateway__pb2.DeployPackOnAgentRequest.SerializeToString,
            grpc__pb_dot_grpc__gateway__pb2.DeployPackOnAgentResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def CoreOsqPackUpdate(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/grpc_gateway.GrpcGateway/CoreOsqPackUpdate',
            grpc__pb_dot_grpc__gateway__pb2.CoreOsqPackUpdateRequest.SerializeToString,
            grpc__pb_dot_grpc__gateway__pb2.CoreOsqPackUpdateResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def DeletePackOnAgent(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/grpc_gateway.GrpcGateway/DeletePackOnAgent',
            grpc__pb_dot_grpc__gateway__pb2.DeletePackOnAgentRequest.SerializeToString,
            grpc__pb_dot_grpc__gateway__pb2.DeletePackOnAgentResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def TakeActionAgent(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/grpc_gateway.GrpcGateway/TakeActionAgent',
            grpc__pb_dot_grpc__gateway__pb2.TakeActionAgentRequest.SerializeToString,
            grpc__pb_dot_grpc__gateway__pb2.TakeActionAgentResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def CheckCanTakeActionAgent(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/grpc_gateway.GrpcGateway/CheckCanTakeActionAgent',
            grpc__pb_dot_grpc__gateway__pb2.CheckCanTakeActionAgentRequest.SerializeToString,
            grpc__pb_dot_grpc__gateway__pb2.CheckCanTakeActionAgentResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def ReceiveScaScanReq(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/grpc_gateway.GrpcGateway/ReceiveScaScanReq',
            grpc__pb_dot_grpc__gateway__pb2.ReceiveScaScanReqRequest.SerializeToString,
            grpc__pb_dot_grpc__gateway__pb2.ReceiveScaScanReqResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def AgentSystemPosture(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/grpc_gateway.GrpcGateway/AgentSystemPosture',
            grpc__pb_dot_grpc__gateway__pb2.AgentSystemPostureRequest.SerializeToString,
            grpc__pb_dot_grpc__gateway__pb2.AgentSystemPostureResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def RunPolicyPackQueries(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/grpc_gateway.GrpcGateway/RunPolicyPackQueries',
            grpc__pb_dot_grpc__gateway__pb2.RunPolicyPackQueriesRequest.SerializeToString,
            grpc__pb_dot_grpc__gateway__pb2.RunPolicyPackQueriesResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def GetServiceData(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/grpc_gateway.GrpcGateway/GetServiceData',
            grpc__pb_dot_grpc__gateway__pb2.GetServiceDataRequest.SerializeToString,
            grpc__pb_dot_grpc__gateway__pb2.GetServiceDataResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)

    @staticmethod
    def SuricataCustomRulesetSync(request,
            target,
            options=(),
            channel_credentials=None,
            call_credentials=None,
            insecure=False,
            compression=None,
            wait_for_ready=None,
            timeout=None,
            metadata=None):
        return grpc.experimental.unary_unary(request, target, '/grpc_gateway.GrpcGateway/SuricataCustomRulesetSync',
            grpc__pb_dot_grpc__gateway__pb2.SuricataCustomRulesetSyncRequest.SerializeToString,
            grpc__pb_dot_grpc__gateway__pb2.SuricataCustomRulesetSyncResponse.FromString,
            options, channel_credentials,
            insecure, call_credentials, compression, wait_for_ready, timeout, metadata)
