package cloud.pposiraegi.order.global.config;

import cloud.pposiraegi.grpc.product.ProductGrpcServiceGrpc;
import cloud.pposiraegi.grpc.user.UserGrpcServiceGrpc;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.grpc.client.GrpcChannelFactory;

@Configuration
public class GrpcClientConfig {

    @Bean
    public ProductGrpcServiceGrpc.ProductGrpcServiceBlockingStub productStub(GrpcChannelFactory channelFactory) {
        return ProductGrpcServiceGrpc.newBlockingStub(channelFactory.createChannel("product-service"));
    }

    @Bean
    public UserGrpcServiceGrpc.UserGrpcServiceBlockingStub userStub(GrpcChannelFactory channelFactory) {
        return UserGrpcServiceGrpc.newBlockingStub(channelFactory.createChannel("user-service"));
    }
}