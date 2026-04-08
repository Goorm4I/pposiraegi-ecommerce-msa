package cloud.pposiraegi.product.domain.repository;

import cloud.pposiraegi.product.domain.entity.ProductOptionValue;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface ProductOptionValueRepository extends JpaRepository<ProductOptionValue, Long> {
    List<ProductOptionValue> findByOptionIdIn(Collection<Long> optionIds);
}
