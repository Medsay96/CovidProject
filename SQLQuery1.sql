SELECT*
FROM CovidProject..CovidDeaths$
ORDER BY 3,4

SELECT*
FROM CovidProject..CovidVaccinations$
ORDER BY 3,4


------------------------------------------------------------------------------------------------------------------
--Selectionner les données qu'on vas utilisé
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths$
ORDER BY 1,2


------------------------------------------------------------------------------------------------------------------
-- Regardez le nombre total de cas par rapport au nombre total de décès
SELECT location, date, total_cases, total_deaths,(cast(total_deaths AS float)/cast(total_cases AS float))*100 AS DeathsPercentage
FROM CovidProject..CovidDeaths$
WHERE location LIKE 'morocco'
ORDER BY 1,2


------------------------------------------------------------------------------------------------------------------
-- En regardant le nombre total de cas par rapport à la population
-- Montre quel pourcentage de la population a contracté le covid
SELECT location, date, total_cases, population,(cast(total_cases AS float)/population)*100 AS PercentPopulationInfect
FROM CovidProject..CovidDeaths$
WHERE location = 'morocco'
ORDER BY 1,2


------------------------------------------------------------------------------------------------------------------
--  En examinant les pays avec le taux d'infection le plus élevé par rapport à la population
SELECT location, MAX(cast(total_cases AS float)) AS HeightsInfectCount, population,MAX(cast(total_cases AS float)/ population )*100 AS PercentPopulationInfect
FROM CovidProject..CovidDeaths$
--WHERE location = 'morocco'
GROUP BY location, population
ORDER BY PercentPopulationInfect DESC


------------------------------------------------------------------------------------------------------------------
-- Montrant les pays avec le plus grand nombre de décès par population
SELECT location, MAX(cast(total_deaths AS float)) AS TotalDeathsCount
FROM CovidProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathsCount DESC


------------------------------------------------------------------------------------------------------------------
-- Montrant le continent avec le plus grand nombre de décès par population
SELECT continent, MAX(cast(total_deaths AS float)) AS TotalDeathsCount
FROM CovidProject..CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathsCount DESC


------------------------------------------------------------------------------------------------------------------
--GLOBAL NUMBERS
SELECT SUM(cast(new_cases as float)) AS Total_Cases, SUM(cast(new_deaths AS float)) AS Total_deaths, NULLIF(SUM(cast(new_deaths AS float)),0)/NULLIF(SUM(cast(new_cases as float)),0)*100 AS DeathPercentage
FROM CovidProject..CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


------------------------------------------------------------------------------------------------------------------
--Regardant la population totale par rapport à la vaccination totale
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths$ dea
JOIN CovidProject..CovidVaccinations$ vac
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

/* Utilisation de CTE */
WITH PopvcVac (continent, location, date, population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths$ dea
JOIN CovidProject..CovidVaccinations$ vac
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT*,(RollingPeopleVaccinated/population)*100
FROM PopvcVac

/* Utilisation TEMP TABLE */
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date DATETIME,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric,
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths$ dea
JOIN CovidProject..CovidVaccinations$ vac
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT*,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


------------------------------------------------------------------------------------------------------------------
--Création d'une vue pour stocker des données
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(float,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths$ dea
JOIN CovidProject..CovidVaccinations$ vac
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT*
FROM PercentPopulationVaccinated 

