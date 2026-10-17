package com.example.mediroutine.repository;

import com.example.mediroutine.entity.MedicineSchedule;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.time.LocalTime;
import java.util.List;
import java.util.Optional;

public interface MedicineScheduleRepository
        extends JpaRepository<MedicineSchedule, Long> {

<<<<<<< Updated upstream
    List<MedicineSchedule> findByMedicineUserId(Long userId);

    Optional<MedicineSchedule> findByIdAndMedicineId(
            Long scheduleId,
            Long medicineId
    );

    List<MedicineSchedule> findByMedicineId(
            Long medicineId
    );

//
//    startDate <= today AND endDate >= today
    List<MedicineSchedule> findByStartDateLessThanEqualAndEndDateGreaterThanEqual(LocalDate date1, LocalDate date2);

    List<MedicineSchedule> findByStartDateLessThanEqualAndEndDateIsNull(LocalDate date1);
}
=======
    List<MedicineSchedule> findByMedicineId(Long medicineId);

    @Query("SELECT s FROM MedicineSchedule s WHERE s.medicine.user.id = :userId")
    List<MedicineSchedule> findByUserId(@Param("userId") Long userId);
}
>>>>>>> Stashed changes
