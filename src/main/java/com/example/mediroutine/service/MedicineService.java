package com.example.mediroutine.service;

import com.example.mediroutine.entity.Medicine;
import com.example.mediroutine.repository.MedicineRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class MedicineService
{

    private final MedicineRepository medicineRepository;

    public MedicineService(MedicineRepository medicineRepository) {
        this.medicineRepository = medicineRepository;
    }

    public List<Medicine> getAllMedicines() {
        return medicineRepository.findAll();
    }

    public Optional<Medicine> getMedicineById(Long id) {
        return medicineRepository.findById(id);
    }

    public List<Medicine> getMedicinesByUserId(Long userId) {
        return medicineRepository.findByUserId(userId);
    }

    public Medicine saveMedicine(Medicine medicine) {
        return medicineRepository.save(medicine);
    }

    public void deleteMedicineById(Long id) {
        medicineRepository.deleteById(id);
    }
}
