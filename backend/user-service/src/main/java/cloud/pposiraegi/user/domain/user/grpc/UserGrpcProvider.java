package cloud.pposiraegi.user.domain.user.grpc;

import cloud.pposiraegi.grpc.user.UserAddressRequest;
import cloud.pposiraegi.grpc.user.UserAddressResponse;
import cloud.pposiraegi.grpc.user.UserGrpcServiceGrpc;
import cloud.pposiraegi.user.domain.user.dto.UserAddressInfoDto;
import cloud.pposiraegi.user.domain.user.service.UserAddressQueryService;
import io.grpc.stub.StreamObserver;
import lombok.RequiredArgsConstructor;
import org.springframework.grpc.server.service.GrpcService;

@GrpcService
@RequiredArgsConstructor
public class UserGrpcProvider extends UserGrpcServiceGrpc.UserGrpcServiceImplBase {
    private final UserAddressQueryService userAddressQueryService;

    @Override
    public void getLastUsedAddress(UserAddressRequest request, StreamObserver<UserAddressResponse> responseObserver) {
        UserAddressInfoDto.UserAddressInfo address = userAddressQueryService.getLastUsedAddress(request.getUserId());

        UserAddressResponse.Builder responseBuilder = UserAddressResponse.newBuilder();

        if (address != null) {
            responseBuilder
                    .setAddressId(address.addressId())
                    .setRecipientName(address.recipientName())
                    .setZipCode(address.zipCode())
                    .setBaseAddress(address.baseAddress())
                    .setDetailAddress(address.detailAddress())
                    .setPhoneNumber(address.phoneNumber())
                    .setSecondaryPhoneNumber(address.secondaryPhoneNumber() != null ? address.secondaryPhoneNumber() : "")
                    .setRequestMessage(address.requestMessage() != null ? address.requestMessage() : "");
        }

        responseObserver.onNext(responseBuilder.build());
        responseObserver.onCompleted();
    }
}