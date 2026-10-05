package com.example.mediroutine.service;

import com.example.mediroutine.dto.AddMedicineRequest;
import com.example.mediroutine.dto.MedicineRequest;
import com.example.mediroutine.dto.MedicineScheduleRequest;
import com.example.mediroutine.entity.Medicine;
import com.example.mediroutine.entity.MedicineSchedule;
import com.example.mediroutine.entity.User;
import com.example.mediroutine.repository.MedicineRepository;
import com.example.mediroutine.repository.MedicineScheduleRepository;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class MedicineService
{

    private final MedicineRepository medicineRepository;
    private final MedicineScheduleRepository medicineScheduleRepository;

    public MedicineService(MedicineRepository medicineRepository, MedicineScheduleRepository medicineScheduleRepository) {
        this.medicineRepository = medicineRepository;
        this.medicineScheduleRepository = medicineScheduleRepository;
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



    @Transactional
    public Medicine addMedicineWithSchedule(AddMedicineRequest request, User user) {

        // 1) save medicine
        MedicineRequest medicineRequest = request.getMedicine();

        Medicine medicine = new Medicine();
        medicine.setName(medicineRequest.getName());
        medicine.setDescription(medicineRequest.getDescription());
        medicine.setUser(user);

        Medicine savedMedicine = medicineRepository.save(medicine);

        // 2) Medicine Schedule
        MedicineScheduleRequest medicineScheduleRequest  =request.getSchedule();

        MedicineSchedule schedule=new MedicineSchedule();
        schedule.setMedicine(savedMedicine);
        schedule.setDosage(medicineScheduleRequest.getDosage());
        schedule.setQuantity(medicineScheduleRequest.getQuantity());
        schedule.setUnit(medicineScheduleRequest.getUnit());
        schedule.setTime(medicineScheduleRequest.getTime());
        schedule.setPeriod(medicineScheduleRequest.getPeriod());
        schedule.setFrequencyType(medicineScheduleRequest.getFrequencyType());
        schedule.setIntervalDays(medicineScheduleRequest.getIntervalDays());
        schedule.setDaysOfWeek(medicineScheduleRequest.getDaysOfWeek());
        schedule.setStartDate(medicineScheduleRequest.getStartDate());
        schedule.setEndDate(medicineScheduleRequest.getEndDate());

        medicineScheduleRepository.save(schedule);

        return savedMedicine;
    }
}
