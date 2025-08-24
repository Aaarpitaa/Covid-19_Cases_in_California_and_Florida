# COVID-19 Case Trends in California vs. Florida

## Project Summary
- This project examines how COVID-19 case averages evolved in California and Florida between January 2020 and January 2022, with a focus on how state-level policies—such as stay-at-home orders, mask mandates, and vaccination campaigns—shaped those trends. These two states were chosen because they represent contrasting policy approaches to the pandemic.

## Data Sources
- We worked with five datasets:
	•	Daily cases and deaths (CDC)
	•	Vaccination coverage (CDC)
	•	2019 state population estimates (U.S. Census Bureau)
	•	Stay-at-home order dates (COVID-19 U.S. State Policies Database)
	•	Mask mandate timelines (COVID-19 U.S. State Policies Database)

## Methods
- Calculated 7-day average case rates to smooth daily fluctuations
- Merged policy timelines (stay-at-home, mask mandates, vaccination milestones at 25% and 75%) with case data
- Visualized trends using LOESS curves to highlight case trajectories alongside policy interventions.
- Compared trends between states to assess how different policy strategies may have influenced case spikes.

## Results
- In summer 2020, Florida experienced a sharper increase in COVID-19 cases following the early termination of stay-at-home orders, whereas California maintained restrictions longer and saw a more moderate rise. During the fall 2021 Delta wave, both states reported increases in cases after lifting mask mandates, with a larger surge observed in Florida. In winter 2021–2022, the Omicron variant was associated with marked spikes in both states despite high vaccination coverage; California’s peak occurred slightly later, potentially reflecting earlier uptake of booster doses. Although both states achieved 25% full vaccination by April 2021, California reached 75% coverage approximately two months sooner than Florida, supported by vaccine mandates and incentive programs.

## Conclusion
Despite adopting very different public health strategies, California and Florida ended up with similar overall case trajectories. Policy differences appeared to influence the timing and intensity of individual spikes, but not the long-term average case burden.
