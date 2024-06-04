SELECT *
FROM [Portfolio Project].dbo.CovidDeaths 
WHERE Continent is not null
order by 3, 4

--SELECT *
--FROM [Portfolio Project].dbo.CovidVaccinations
--order by 3, 4

--Select Data that we are going to be using 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM [Portfolio Project].dbo.CovidDeaths 
WHERE Continent is not null
order by 1, 2


-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract Covid in your country
SELECT Location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths 
WHERE Location = 'United States'
order by 1, 2

-- Looking at the total cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, Population, total_cases,  (total_cases/ Population)*100 AS PercentPopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths 
WHERE Location = 'United States'
order by 1, 2

-- Looking at countries with highest infection rate compared to population
SELECT Location,  Population, MAX(total_cases) AS HighestInfectionCount,  MAX((total_cases/ Population))*100 AS PercentPopulationInfected
FROM [Portfolio Project].dbo.CovidDeaths 
GROUP BY Location, Population
order by PercentPopulationInfected DESC

-- Showing countries with highest Death Count per Population
SELECT Location,  MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths 
WHERE Continent is null
GROUP BY Location 
order by TotalDeathCount DESC



-- Showing the continents with the highest death count per population
SELECT continent,  MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM [Portfolio Project].dbo.CovidDeaths 
WHERE Continent is not null
GROUP BY continent
order by TotalDeathCount DESC

--Global Numbers
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, (SUM(CONVERT(int, new_deaths)) / SUM(New_Cases)) * 100 AS DeathPercentage
FROM [Portfolio Project].dbo.CovidDeaths 
--WHERE Location = 'United States'
WHERE Continent is not null
--Group By Date
order by 1, 2


-- Looking at Total Population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date) as RollingPeopleVaccinated, 
--MAX(RollingPeopleVaccinated)/
FROM [Portfolio Project].dbo.CovidDeaths dea
JOIN [Portfolio Project].dbo.CovidVaccinations vac
	ON dea.Location = vac.Location 
	AND dea.Date = vac.Date
WHERE dea.continent is not null
order by 2, 3

-- USING CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated) 
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidDeaths dea
JOIN [Portfolio Project].dbo.CovidVaccinations vac
	ON dea.Location = vac.Location 
	AND dea.Date = vac.Date
WHERE dea.continent is not null
--order by 2, 3
)
SELECT * , (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--USING temporary table

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(225), 
Location nvarchar(225), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidDeaths dea
JOIN [Portfolio Project].dbo.CovidVaccinations vac
	ON dea.Location = vac.Location 
	AND dea.Date = vac.Date
WHERE dea.continent is not null
--order by 2, 3

SELECT * , (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualization

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations AS int)) OVER (Partition by dea.Location ORDER BY dea.Location, dea.Date) as RollingPeopleVaccinated
FROM [Portfolio Project].dbo.CovidDeaths dea
JOIN [Portfolio Project].dbo.CovidVaccinations vac
	ON dea.Location = vac.Location 
	AND dea.Date = vac.Date
WHERE dea.continent is not null
--order by 2, 3

SELECT * 
FROM PercentPopulationVaccinated