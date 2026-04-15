package cloud.pposiraegi.product.domain.repository;

import cloud.pposiraegi.product.domain.entity.TimeDeal;
import cloud.pposiraegi.product.domain.enums.TimeDealStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface TimeDealRepository extends JpaRepository<TimeDeal, Long> {
    List<TimeDeal> findByStatusAndStartTimeLessThanEqual(TimeDealStatus status, LocalDateTime time);

    List<TimeDeal> findByStatusAndEndTimeLessThanEqual(TimeDealStatus status, LocalDateTime time);

    List<TimeDeal> findAllByIdIn(List<Long> ids);

    List<TimeDeal> findByStatusAndStartTimeBetween(TimeDealStatus status, LocalDateTime start, LocalDateTime end);

    Optional<TimeDeal> findByProductIdAndStatus(Long productId, TimeDealStatus status);

    @Query("SELECT t, p FROM TimeDeal t JOIN Product p ON t.productId = p.id WHERE (:status IS NULL OR t.status = :status)")
    List<Object[]> findTimeDealsWithProducts(@Param("status") TimeDealStatus status);

    @Query("SELECT t, p FROM TimeDeal t JOIN Product p ON t.productId = p.id WHERE t.status != :excludeStatus")
    List<Object[]> findTimeDealsWithProductsExcludingStatus(@Param("excludeStatus") TimeDealStatus excludeStatus);
}
