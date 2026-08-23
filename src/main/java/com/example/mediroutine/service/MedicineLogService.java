package com.example.mediroutine.service;

import com.example.mediroutine.entity.MedicineLog;
import com.example.mediroutine.repository.MedicineLogRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class MedicineLogService {

    private final MedicineLogRepository medicineLogRepository;

    public MedicineLogService(MedicineLogRepository medicineLogRepository) {
        this.medicineLogRepository = medicineLogRepository;
    }

    public List<MedicineLog> getAllLogs() {
        return medicineLogRepository.findAll();
    }

    public Optional<MedicineLog> getLogById(Long id) {
        return medicineLogRepository.findById(id);
    }

    public List<MedicineLog> getLogsByScheduleId(Long scheduleId) {
        return medicineLogRepository.findByScheduleId(scheduleId);
    }

    public MedicineLog saveLog(MedicineLog log) {
        return medicineLogRepository.save(log);
    }

    public void deleteLogById(Long id) {
        medicineLogRepository.deleteById(id);
    }
}
