const express = require('express');
const router = express.Router();

// Sample data (replace with database)
let pets = [
  {
    id: '1',
    name: '멍멍이',
    species: 'dog',
    breed: '골든 리트리버',
    birthDate: new Date(Date.now() - 365 * 2 * 24 * 60 * 60 * 1000).toISOString(),
    weight: 25.5,
    gender: 'male',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
  {
    id: '2',
    name: '냥냥이',
    species: 'cat',
    breed: '페르시안',
    birthDate: new Date(Date.now() - 365 * 1 * 24 * 60 * 60 * 1000).toISOString(),
    weight: 4.2,
    gender: 'female',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  },
];

// Get all pets
router.get('/', (req, res) => {
  res.json(pets);
});

// Get pet by ID
router.get('/:id', (req, res) => {
  const pet = pets.find(p => p.id === req.params.id);
  if (!pet) {
    return res.status(404).json({ message: 'Pet not found' });
  }
  res.json(pet);
});

// Create new pet
router.post('/', (req, res) => {
  const { name, species, breed, birthDate, weight, gender, microchipId } = req.body;
  
  if (!name || !species || !breed || !birthDate || !weight || !gender) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  const newPet = {
    id: Date.now().toString(),
    name,
    species,
    breed,
    birthDate,
    weight: parseFloat(weight),
    gender,
    microchipId: microchipId || null,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };

  pets.push(newPet);
  res.status(201).json(newPet);
});

// Update pet
router.put('/:id', (req, res) => {
  const petIndex = pets.findIndex(p => p.id === req.params.id);
  if (petIndex === -1) {
    return res.status(404).json({ message: 'Pet not found' });
  }

  const { name, species, breed, birthDate, weight, gender, microchipId } = req.body;
  
  pets[petIndex] = {
    ...pets[petIndex],
    name: name || pets[petIndex].name,
    species: species || pets[petIndex].species,
    breed: breed || pets[petIndex].breed,
    birthDate: birthDate || pets[petIndex].birthDate,
    weight: weight ? parseFloat(weight) : pets[petIndex].weight,
    gender: gender || pets[petIndex].gender,
    microchipId: microchipId !== undefined ? microchipId : pets[petIndex].microchipId,
    updatedAt: new Date().toISOString(),
  };

  res.json(pets[petIndex]);
});

// Delete pet
router.delete('/:id', (req, res) => {
  const petIndex = pets.findIndex(p => p.id === req.params.id);
  if (petIndex === -1) {
    return res.status(404).json({ message: 'Pet not found' });
  }

  pets.splice(petIndex, 1);
  res.status(204).send();
});

module.exports = router; 