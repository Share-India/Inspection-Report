import { Injectable } from '@angular/core';

@Injectable({
    providedIn: 'root'
})
export class RiskScoringService {

    constructor() { }

    calculateScore(data: any): { actualScore: number, potentialScore: number, rating: string, actualPercent: number, potentialPercent: number } {
        if (!data) {
            console.warn('RiskScoring: No data provided for calculation');
            return { actualScore: 0, potentialScore: 0, rating: 'N/A', actualPercent: 0, potentialPercent: 0 };
        }

        console.log('RiskScoring: Calculating Score for data:', data);

        let totalPossible = 0;
        let actualPoints = 0;
        let potentialRepairable = 0;

        // Helper to check for "true" whether boolean or string
        const isTrue = (val: any) => val === true || val === 'true';

        // Step 1: Human Element
        totalPossible += 50; // 5 questions * 10
        // Housekeeping: Good answer starts with "No RM, FG and WIP are stored...". Bad ones mention "Poor", "Haphazard", "Stocks are stored beneath".
        // Fix: Check for positive keyword "orderly" which is in the good answer, or check for specific bad starts.
        // Good Answer: "No RM, FG ... orderly ..."
        if (data.housekeeping && data.housekeeping.includes('orderly')) {
            actualPoints += 10;
        } else {
            potentialRepairable += 10;
        }

        if (isTrue(data.fireTraining)) actualPoints += 10; else potentialRepairable += 10;

        // Fire Protection: Good if it contains "TAC" or "IS 2190" or "Fire brigade". Bad if "Non Standard" or "No protection".
        if (data.fireProtection) {
            const fp = Array.isArray(data.fireProtection) ? data.fireProtection.join(' ') : data.fireProtection;
            if (fp.includes('TAC') || fp.includes('IS 2190') || fp.includes('Fire brigade')) {
                actualPoints += 10;
            } else {
                potentialRepairable += 10;
            }
        } else {
            potentialRepairable += 10;
        }

        if (isTrue(data.maintenance)) actualPoints += 10; else potentialRepairable += 10;
        if (isTrue(data.hotWorkPermit)) actualPoints += 10; else potentialRepairable += 10;

        // Step 2: Occupancy Hazard
        totalPossible += 40; // 4 questions
        // Combustible Materials: No is safer (10pts).
        if (data.combustibleMaterials === false || data.combustibleMaterials === 'false') actualPoints += 10; else potentialRepairable += 10;

        // Flammable Solvents: "No Solvent" is safest.
        if (data.flammableSolvents && data.flammableSolvents.includes('No Solvent')) actualPoints += 10; else potentialRepairable += 10;

        // Flame Proof Cables: Yes is safer.
        if (isTrue(data.flameProofCables)) actualPoints += 10; else potentialRepairable += 10;

        // Electrical Fittings: Steel/PVC Conduit is better than Loose.
        if (data.electricalFittings && (data.electricalFittings.includes('Steel Conduit') || data.electricalFittings.includes('PVC'))) actualPoints += 10; else potentialRepairable += 10;


        // Step 3: Surveillance
        totalPossible += 40;
        if (isTrue(data.smokeDetection)) actualPoints += 10; else potentialRepairable += 10;
        if (isTrue(data.cctv)) actualPoints += 10; else potentialRepairable += 10;
        if (data.boundaryWalls && data.boundaryWalls.includes('Yes')) actualPoints += 10; else potentialRepairable += 10;
        if (isTrue(data.securityTeam)) actualPoints += 10; else potentialRepairable += 10;

        // Step 4: Construction
        totalPossible += 30;
        // Construction Type: RCC is best.
        if (data.constructionType && data.constructionType.includes('RCC')) actualPoints += 10; else potentialRepairable += 10;

        // Separation: >21m is best.
        if (data.separationDistance === '>21mtrs') actualPoints += 10;
        else if (data.separationDistance === '16 to 20mtrs') { actualPoints += 5; potentialRepairable += 5; }
        else potentialRepairable += 10;

        // Basement: No is best. UNFIXABLE if Yes.
        if (data.basementRisk === false || data.basementRisk === 'false') actualPoints += 10;
        // If Yes, 0 points and 0 potential (Unfixable)

        // Step 5: External Exposure
        totalPossible += 30;
        // External Occupancies: "Does not share" is best. UNFIXABLE if shares.
        if (data.externalOccupancies && data.externalOccupancies.includes('Does not share')) actualPoints += 10;
        // If shares, 0 points and 0 potential

        // Water Body: No is best. UNFIXABLE if Yes.
        if (data.waterBody === false || data.waterBody === 'false') actualPoints += 10;
        // If Yes, 0 points and 0 potential

        // Natural Hazards: No is best. UNFIXABLE if Yes.
        if (data.naturalHazards === false || data.naturalHazards === 'false') actualPoints += 10;
        // If Yes, 0 points and 0 potential

        // Step 6: Fire Protection
        totalPossible += 60;
        // Check if value exists and is not 'Select' or empty
        const isValid = (val: any) => val && val !== 'Select' && val !== '';
        // Helper for capacity scoring: Low capacity = 5pts, High = 10pts
        const scoreCapacity = (val: string) => {
            if (!isValid(val)) return { actual: 0, potential: 10 };
            if (val.includes('Less than')) return { actual: 5, potential: 5 }; // 5 pts + 5 potential to upgrade
            return { actual: 10, potential: 0 }; // Full points
        };

        const ftScore = scoreCapacity(data.fireWaterTank);
        actualPoints += ftScore.actual; potentialRepairable += ftScore.potential;

        const mepScore = scoreCapacity(data.mainElectricalPump);
        actualPoints += mepScore.actual; potentialRepairable += mepScore.potential;

        const ddpScore = scoreCapacity(data.dieselDrivenPump);
        actualPoints += ddpScore.actual; potentialRepairable += ddpScore.potential;

        const jpScore = scoreCapacity(data.jockeyPump);
        actualPoints += jpScore.actual; potentialRepairable += jpScore.potential;

        const hpScore = scoreCapacity(data.hydrantPoints);
        actualPoints += hpScore.actual; potentialRepairable += hpScore.potential;

        const feScore = scoreCapacity(data.fireExtinguishers);
        actualPoints += feScore.actual; potentialRepairable += feScore.potential;


        // Calculations
        const actualPercent = totalPossible > 0 ? (actualPoints / totalPossible) * 100 : 0;
        const potentialScore = actualPoints + potentialRepairable; // Only adds repairable points
        const potentialPercent = totalPossible > 0 ? (potentialScore / totalPossible) * 100 : 0;

        let rating = 'Average Risk';
        if (actualPercent < 60) rating = 'Poor Risk';
        else if (actualPercent >= 75) rating = 'Good Risk';

        console.log(`RiskScoring: Points=${actualPoints}/${totalPossible}, Actual%=${actualPercent}, Potential%=${potentialPercent}`);

        return {
            actualScore: actualPoints,
            potentialScore: potentialScore,
            rating: rating,
            actualPercent: parseFloat(actualPercent.toFixed(2)),
            potentialPercent: parseFloat(potentialPercent.toFixed(2))
        };
    }
}
