package com.example.mediroutine.service;

import com.example.mediroutine.dto.UpdateMedicineScheduleRequest;
import com.example.mediroutine.entity.Medicine;
import com.example.mediroutine.entity.MedicineSchedule;
import com.example.mediroutine.repository.MedicineScheduleRepository;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class MedicineScheduleService {

    private final MedicineScheduleRepository medicineScheduleRepository;

    public MedicineScheduleService(
            MedicineScheduleRepository medicineScheduleRepository
    ) {
        this.medicineScheduleRepository = medicineScheduleRepository;
    }

    public MedicineSchedule saveSchedule(MedicineSchedule schedule) {
        return medicineScheduleRepository.save(schedule);
    }

    public Optional<MedicineSchedule> getScheduleById(Long id) {
        return medicineScheduleRepository.findById(id);
    }

    public List<MedicineSchedule> getSchedulesByMedicineId(
            Long medicineId
    ) {
        return medicineScheduleRepository.findByMedicineId(medicineId);
    }

    public List<MedicineSchedule> getSchedulesByUserId(
            Long userId
    ) {
        return medicineScheduleRepository.findByMedicineUserId(userId);
    }

    public void deleteMedicineScheduleById(Long id) {
        medicineScheduleRepository.deleteById(id);
    }

    @Transactional
    public MedicineSchedule updateSchedulePartial(
            Long scheduleId,
            UpdateMedicineScheduleRequest request,
            Medicine medicine
    ) {

        MedicineSchedule schedule =
                medicineScheduleRepository.findById(scheduleId)
                        .orElseThrow(() ->
                                new RuntimeException("Schedule not found")
                        );

        /*
         * Medicine is only changed when medicineId
         * is actually provided.
         */
        if (request.getMedicineId() != null) {
            schedule.setMedicine(medicine);
        }

        if (request.getDosage() != null) {
            schedule.setDosage(request.getDosage());
        }

        if (request.getQuantity() != null) {
            schedule.setQuantity(request.getQuantity());
        }

        if (request.getUnit() != null) {
            schedule.setUnit(request.getUnit());
        }

        if (request.getTime() != null) {
            schedule.setTime(request.getTime());
        }

        if (request.getPeriod() != null) {
            schedule.setPeriod(request.getPeriod());
        }

        if (request.getFrequencyType() != null) {
            schedule.setFrequencyType(request.getFrequencyType());
        }

        if (request.getIntervalDays() != null) {
            schedule.setIntervalDays(request.getIntervalDays());
        }

        if (request.getDaysOfWeek() != null) {
            schedule.setDaysOfWeek(request.getDaysOfWeek());
        }

        if (request.getStartDate() != null) {
            schedule.setStartDate(request.getStartDate());
        }

        if (request.getEndDate() != null) {
            schedule.setEndDate(request.getEndDate());
        }

        return medicineScheduleRepository.save(schedule);
    }
}