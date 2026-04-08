package cloud.pposiraegi.product.domain.repository;

import cloud.pposiraegi.product.domain.entity.Product;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ProductRepository extends JpaRepository<Product, Long> {
    public List<Product> findByCategoryId(Long categoryId);

    public List<Product> findByStatus(String status);
}
