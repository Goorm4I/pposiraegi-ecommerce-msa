package cloud.pposiraegi.order.domain.grpc;

import cloud.pposiraegi.grpc.user.UserAddressRequest;
import cloud.pposiraegi.grpc.user.UserAddressResponse;
import cloud.pposiraegi.grpc.user.UserGrpcServiceGrpc;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
public class UserGrpcClient {
    private final UserGrpcServiceGrpc.UserGrpcServiceBlockingStub userStub;

    public UserAddressResponse getLastUsedAddress(Long userId) {
        UserAddressRequest request = UserAddressRequest.newBuilder()
                .setUserId(userId)
                .build();

        return userStub.getLastUsedAddress(request);
    }
}
