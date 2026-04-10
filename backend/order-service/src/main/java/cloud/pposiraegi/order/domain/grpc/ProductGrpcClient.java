package cloud.pposiraegi.order.domain.grpc;

import cloud.pposiraegi.grpc.product.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
@RequiredArgsConstructor
public class ProductGrpcClient {

    private final ProductGrpcServiceGrpc.ProductGrpcServiceBlockingStub productStub;

    public List<SkuInfo> getSkuInfos(List<Long> skuIds) {
        SkuInfoRequest request = SkuInfoRequest.newBuilder()
                .addAllSkuIds(skuIds)
                .build();

        SkuInfoResponse response = productStub.getSkuInfos(request);
        return response.getSkuInfosList();
    }

    public Integer getSkuPurchaseLimit(Long skuId) {
        PurchaseLimitRequest request = PurchaseLimitRequest.newBuilder()
                .setSkuId(skuId)
                .build();

        PurchaseLimitResponse response = productStub.getSkuPurchaseLimit(request);
        return response.getPurchaseLimit();
    }
}