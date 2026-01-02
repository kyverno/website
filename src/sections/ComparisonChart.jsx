import { Table } from '../components/Table'
import { comparisonChartHeadingContent } from '../constants'

export const ComparisonChart = () => {
  const { headingText, paragraphText } = comparisonChartHeadingContent

  return (
    <section className="flex flex-col justify-center items-center pb-6 px-6">
      <div className="items-center flex flex-col space-y-6 my-5">
        <h2
          className="text-4xl font-bold tracking-wide
                capitalize text-center"
        >
          Kyverno Vs
          <span className="text-primary-100"> Other policy engines</span>
        </h2>
        <p className="min-w-80 text-[1rem] w-80 sm:text-lg sm:min-w-150 text-center text-white/80">
          As the industry's leading policy engine, here's how Kyverno compares
          with other policy engines.
        </p>
      </div>
      <div
        className="flex justify-center items-center w-full md:max-w-260 
        bg-dark-50 border border-stroke p-6 rounded-2xl sm:overflow-x-auto text-[16px] mt-8"
      >
        <Table />
      </div>
    </section>
  )
}
