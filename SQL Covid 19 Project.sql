Select *
From CovidDeaths$
Order by 3,4

--Select *
--From CovidVaccinations$
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From CovidDeaths$
Order by 1,2

--Looking at total cases VS total deaths
--Shows percentage of total deaths in specific location
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
From CovidDeaths$
Where location like '%states%'
Order by 1,2

--Looking at total case VS population
--Shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 AS InfectedPopulationPercentage
From CovidDeaths$
Where location like '%states%'
Order by 1,2

--Countries with highest infection rate compared to population
Select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS InfectedPopulationPercentage
From CovidDeaths$
--Where location like '%states%'
Group by location, population
Order by InfectedPopulationPercentage desc

--Showing countries with highest death count per population
Select location,MAX(cast (Total_deaths AS Int)) AS TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Showing continent with highest death count per population
Select continent,MAX(cast (Total_deaths AS Int)) AS TotalDeathCount
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc



--GLOBAL NUMBERS

--Total cases and deaths with death percentage with respect to date  
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths AS int)) as total_deaths ,(SUM(cast(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

--Total no. of cases deaths and death percentage of the entire world 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths AS int)) as total_deaths ,(SUM(cast(new_deaths AS int))/SUM(new_cases))*100 AS DeathPercentage
From CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2


--Vaccionation Table Analysis


Select*
From CovidVaccinations$

--Joining bith the table i.e. CovidDeaths table and CobidVaccinations table

Select *
From CovidDeaths$ dea
Join CovidVaccinations$ vac
On dea.location=vac.location
and dea.date=vac.date 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From CovidDeaths$ dea
Join CovidVaccinations$ vac
On dea.location=vac.location
and dea.date=vac.date 
Where dea.continent is not null
Order by 2,3

--Looking at Rolling total no. of people vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
On dea.location=vac.location
and dea.date=vac.date 
Where dea.continent is not null
Order by 2,3

--To find percentage of people vaccinated with respect to population
--temp table is required to divide RollingPeopleVaccinated with Population as RollingPeopleVaccinated is not an actual column in the tables 

--Using CTE

With PopvsVac ( Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
On dea.location=vac.location
and dea.date=vac.date 
Where dea.continent is not null
)
Select*,(RollingPeopleVaccinated/Population)*100 AS VaccionationPercentage
From PopvsVac


--TEMP TABLE
Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric 
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
On dea.location=vac.location
and dea.date=vac.date 
Where dea.continent is not null

Select*,(RollingPeopleVaccinated/Population)*100 AS VaccionationPercentage
From #PercentPopulationVaccinated

-- Creating View to store data for visualizations later

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations)) Over (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From CovidDeaths$ dea
Join CovidVaccinations$ vac
On dea.location=vac.location
and dea.date=vac.date 
Where dea.continent is not null

Select*
from PercentPopulationVaccinated