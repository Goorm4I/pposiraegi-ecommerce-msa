package cloud.pposiraegi.product.domain.repository;

import cloud.pposiraegi.product.domain.entity.ProductSku;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductSkuRepository extends JpaRepository<ProductSku, Long> {
    List<ProductSku> findByProductId(Long productId);

}
