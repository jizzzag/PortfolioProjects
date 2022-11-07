select*
from PortfolioProject..CovidDeaths
order by 3,4

--selecting the data we are going to be using
select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2

--looking for Total cases vs total deaths
--shows likelihood of dying if you contact in India
select location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%india%'
order by 1,2

--Looking at total cases vs population
-- shows what percentage of populaton got covid 
select location,date,total_cases,population,(total_cases/population)*100 as Infection_percentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
order by 1,2

--looking at the countries with highest infection rate compared to population 

select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population)*100) as Infection_percentage
from PortfolioProject..CovidDeaths
--where location like '%india%'
group by location,population
order by Infection_percentage desc



--showing countries with highest death count per population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
--where location like '%india%'
group by location
order by TotalDeathCount desc


--showing the continents with highest death count

select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount desc


--GLOBAL NUMBERS

select sum(new_cases),sum(cast(total_deaths as int)) as total_deaths, sum(cast(total_deaths as int))/sum(new_cases)*100 as Death_percentage
from PortfolioProject..CovidDeaths
where continent is null
order by 1,2



--looking at total population vs vaccinations 

select death.continent,death.location,death.date,death.population,vacc.new_vaccinations, sum(convert(int,vacc.new_vaccinations)) over (partition by death.location,death.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vacc 
on death.location=vacc.location
and death.date=vacc.date
where death.continent is not null
order by 2,3


--use cte

with PopvsVac (continent,Location,Date,Population,New_vaccinations,RollingPeopleVaccinated) as

(
select death.continent,death.location,death.date,death.population,vacc.new_vaccinations, sum(convert(int,vacc.new_vaccinations)) over (partition by death.location,death.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vacc 
on death.location=vacc.location
and death.date=vacc.date
where death.continent is not null
 )
select* ,(RollingPeopleVaccinated/Population)*100 from PopvsVac




--TEMP TABLE



create table #PercentPopulationVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select death.continent,death.location,death.date,death.population,vacc.new_vaccinations, sum(convert(int,vacc.new_vaccinations)) over (partition by death.location,death.date) as RollingPeopleVaccinated 
from PortfolioProject..CovidDeaths death
join PortfolioProject..CovidVaccinations vacc 
on death.location=vacc.location
and death.date=vacc.date
where death.continent is not null

select* ,(RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated