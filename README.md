# TP3 - Évaluation des Performances de Mémoires Caches

Travail Pratique sur l'analyse des performances de différentes configurations de mémoires caches pour la multiplication de matrices, réalisé avec le simulateur **gem5**.

## 📋 Description

Ce projet évalue les **miss rates** (taux de défauts) de différentes organisations de caches (instructions et données) pour 4 algorithmes de multiplication de matrices (128×128) :

- **P1 (normale)** : Multiplication classique (i-j-k)
- **P2 (pointer)** : Accès via pointeurs
- **P3 (tempo)** : Cache blocking (tiling)
- **P4 (unrol)** : Loop unrolling

## 🎯 Objectifs

1. Configurer gem5 pour simuler 2 architectures de caches (C1, C2)
2. Mesurer les miss rates pour I-cache, D-cache et L2
3. Analyser la localité de références du code

## 📊 Résultats principaux

### Instruction Cache (IL1) - Miss Rate

| Programme | C1    | C2    |
|-----------|-------|-------|
| normale   | 2.16% | 2.16% |
| pointer   | 0.07% | 0.07% |
| tempo     | 2.33% | 2.32% |
| unrol     | 0.17% | 0.17% |

**→ Excellente localité du code (< 2.5%)**

### Data Cache (DL1) - Miss Rate

| Programme | C1     | C2     | Gain  |
|-----------|--------|--------|-------|
| normale   | 51.43% | 44.65% | -6.78% |
| pointer   | 51.47% | 45.83% | -5.64% |
| tempo     | 50.99% | 44.18% | -6.81% |
| unrol     | 51.53% | 43.98% | -7.55% |

**→ Mauvaise localité des données (capacité insuffisante)**

### L2 Cache (UL2) - Miss Rate

| Programme | C1     | C2     | Gain  |
|-----------|--------|--------|-------|
| normale   | 51.51% | 45.66% | -5.85% |
| pointer   | 50.99% | 44.59% | -6.40% |
| tempo     | 51.55% | 45.92% | -5.63% |
| unrol     | 51.51% | 46.16% | -5.35% |

**→ Problème de capacité (384 kB de données >> 32 kB L2)**

## 🛠️ Outils utilisés

- **Simulateur** : gem5 v23.0.0.1
- **Architecture** : RISC-V 64 bits
- **Langage** : Python (gem5), Bash (automatisation)
- **Environnement** : Docker Ubuntu 24.04

## 📁 Structure du projet

```
tp3-caches/
├── README.md                 # Ce fichier
├── rapport_tp3.tex           # Rapport LaTeX complet
├── rapport_tp3.pdf           # Rapport compilé
├── scripts/
│   ├── se_A7.py              # Configuration gem5
│   ├── simulations.sh        # Lance les 8 simulations
│   └── resultats.sh          # Extrait les miss rates
├── resultats/
│   ├── tp3.png               # Capture d'écran des résultats
│   └── m5out_*/              # Dossiers de sortie gem5
└── programmes/
    ├── normale.riscv
    ├── pointer.riscv
    ├── tempo.riscv
    └── unrol.riscv
```

## 🚀 Installation et utilisation

### Prérequis

- gem5 compilé pour RISC-V
- Environnement Linux (ou Docker)
- Binaires RISC-V des 4 programmes

### Lancement des simulations

```bash
# 1. Rendre les scripts exécutables
chmod +x scripts/*.sh

# 2. Lancer les 8 simulations (2-5 minutes)
cd scripts
./simulations.sh

# 3. Afficher les résultats
./resultats.sh

# 4. Sauvegarder les résultats
./resultats.sh > ../resultats/miss_rates.txt
```

### Compilation du rapport

```bash
# Compiler le rapport LaTeX
pdflatex rapport_tp3.tex
pdflatex rapport_tp3.tex  # 2 fois pour la table des matières
```

## 📈 Configurations de caches testées

### Configuration C1 (Direct-mapped)
- **IL1** : 4 kB, 1-way, LRU, block 32B
- **DL1** : 4 kB, 1-way, LRU, block 32B
- **UL2** : 32 kB, 1-way, LRU, block 32B

### Configuration C2 (Set-associative)
- **IL1** : 4 kB, 1-way, LRU, block 32B
- **DL1** : 4 kB, **2-way**, LRU, block 32B
- **UL2** : 32 kB, **4-way**, LRU, block 32B

## 🔍 Analyse des résultats

### Observations clés

1. **Localité asymétrique** :
   - Code : Excellente (0.07% - 2.33%)
   - Données : Médiocre (44% - 52%)

2. **Effet de l'associativité** :
   - I-cache : Aucun gain C1→C2 (code trop petit)
   - D-cache : Gain modéré 5-7% C1→C2
   - L2 : Gain modéré 5-6% C1→C2

3. **Facteur limitant** : **Capacité** des caches, pas leur organisation
   - 3 matrices = 384 kB
   - DL1 = 4 kB (ratio 96:1)
   - L2 = 32 kB (ratio 12:1)

### Recommandations

Pour améliorer les performances :
- Augmenter le L2 à **512 kB - 1 MB** (contenir les 3 matrices)
- Augmenter le DL1 à **32 kB** (optimiser cache blocking)
- Ajouter un cache L3 de **2-4 MB**
- Augmenter l'associativité du L2 à **8-way ou 16-way**

## 📚 Références

- [Documentation gem5](https://www.gem5.org/documentation/)
- [RISC-V ISA Specification](https://riscv.org/technical/specifications/)
- Hennessy & Patterson, *Computer Architecture: A Quantitative Approach*

## 👥 Auteur

**Votre Nom**  
ES201 - Architecture des Microprocesseurs  
ECE Paris, 2026

## 📄 Licence

Ce projet est réalisé dans le cadre d'un TP académique.

## 🙏 Remerciements

- Équipe gem5 pour le simulateur
- Enseignants du cours ES201
- Communauté RISC-V
