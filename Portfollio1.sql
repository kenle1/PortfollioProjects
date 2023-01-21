Select *
From Portfollio..CovidDeaths$
Where continent is not null
order by 3,4

--Select *
--From Portfollio ..CovidVaccinations$
--order by 3,4 

--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Portfollio ..CovidDeaths$
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfollio ..CovidDeaths$
Where location like '%states%'
and continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid
Select Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From Portfollio ..CovidDeaths$
--Where location like '%states%'
order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as
PercentagePopulationInfected
From Portfollio ..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentagePopulationInfected desc

-- Showing Countries with Highest Death Count per Population
--stop at 31.34 youtube
Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From Portfollio ..CovidDeaths$
--Where location like '%states'
Where continent is not null
Group by location
order by TotalDeathCount desc

--Lets break things down by continent
--Showing continents with highest death count per population
Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From Portfollio ..CovidDeaths$
--Where location like '%states'
Where continent is not null 
Group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

Select Sum(new_cases) as Total_Cases, Sum(cast(new_deaths as int)) as Tota_Deaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 as DeathPercentage
From Portfollio ..CovidDeaths$
--Where Location like '%states%'
where continent is not null
--Group By date
order by 1,2


--Looking at Total Population vs Vaccinations
--USE CTE
With PopvsVac (continent, location, date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfollio ..CovidDeaths$ dea
Join Portfollio ..CovidVaccinations$ vac 
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
From PopvsVac


--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfollio ..CovidDeaths$ dea
Join Portfollio ..CovidVaccinations$ vac 
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated


--Creating View to store data for later vizualizations

Create View PercentPeopleVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Portfollio ..CovidDeaths$ dea
Join Portfollio ..CovidVaccinations$ vac 
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPeopleVaccinated