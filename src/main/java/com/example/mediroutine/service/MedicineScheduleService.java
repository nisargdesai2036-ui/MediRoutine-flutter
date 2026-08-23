package com.example.mediroutine.service;

import com.example.mediroutine.entity.MedicineSchedule;
import com.example.mediroutine.repository.MedicineScheduleRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class MedicineScheduleService {

    private final MedicineScheduleRepository medicineScheduleRepository;

    public MedicineScheduleService(MedicineScheduleRepository medicineScheduleRepository) {
        this.medicineScheduleRepository = medicineScheduleRepository;
    }

    public List<MedicineSchedule> getAllSchedules() {
        return medicineScheduleRepository.findAll();
    }

    public Optional<MedicineSchedule> getScheduleById(Long id) {
        return medicineScheduleRepository.findById(id);
    }

    public List<MedicineSchedule> getSchedulesByMedicineId(Long medicineId) {
        return medicineScheduleRepository.findByMedicineId(medicineId);
    }

    public MedicineSchedule saveSchedule(MedicineSchedule schedule) {
        return medicineScheduleRepository.save(schedule);
    }

    public void deleteScheduleById(Long id) {
        medicineScheduleRepository.deleteById(id);
    }
}
