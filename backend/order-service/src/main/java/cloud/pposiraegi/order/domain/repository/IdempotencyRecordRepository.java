package cloud.pposiraegi.order.domain.repository;

import cloud.pposiraegi.order.domain.entity.IdempotencyRecord;
import org.springframework.data.jpa.repository.JpaRepository;

public interface IdempotencyRecordRepository extends JpaRepository<IdempotencyRecord, String> {

}
