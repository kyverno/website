const StatusIcon = ({ status }) => {
  const normalizedStatus = status?.toLowerCase()

  if (normalizedStatus === 'yes') {
    return (
      <svg
        className="w-7 h-7 flex-shrink-0 text-green-400"
        viewBox="0 0 20 20"
        fill="currentColor"
        xmlns="http://www.w3.org/2000/svg"
      >
        <circle cx="10" cy="10" r="9" fill="currentColor" opacity="0.2" />
        <path
          d="M6 10L9 13L14 7"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
          fill="none"
        />
      </svg>
    )
  }

  if (normalizedStatus === 'limited') {
    return (
      <svg
        className="w-7 h-7 flex-shrink-0 text-orange-400"
        viewBox="0 0 20 20"
        fill="currentColor"
        xmlns="http://www.w3.org/2000/svg"
      >
        <circle cx="10" cy="10" r="9" fill="currentColor" opacity="0.2" />
        <line
          x1="6"
          y1="10"
          x2="14"
          y2="10"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
        />
      </svg>
    )
  }

  if (normalizedStatus === 'no') {
    return (
      <svg
        className="w-7 h-7 flex-shrink-0 text-red-400"
        viewBox="0 0 20 20"
        fill="currentColor"
        xmlns="http://www.w3.org/2000/svg"
      >
        <circle cx="10" cy="10" r="9" fill="currentColor" opacity="0.2" />
        <line
          x1="6"
          y1="6"
          x2="14"
          y2="14"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
        />
        <line
          x1="14"
          y1="6"
          x2="6"
          y2="14"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
        />
      </svg>
    )
  }

  return null
}

const CellContent = ({ text, status }) => {
  return (
    <div className="flex items-center gap-2">
      <StatusIcon status={status} />
      <span className="leading-relaxed">{text}</span>
    </div>
  )
}

export const Table = ({ data = [] }) => {
  return (
    <table className="w-full">
      <thead className="w-full hidden sm:table-header-group">
        <tr className="w-full flex flex-col sm:flex-row sm:justify-between items-start sm:items-center bg-dark-50 rounded-t-2xl gap-4 sm:gap-8 min-h-[80px] py-4">
          <th className="font-bold w-full sm:w-[30%] px-4 sm:px-0 sm:pl-6 text-left flex items-center">
            Feature
          </th>
          <th className="flex items-center space-x-4 px-4 sm:px-0 sm:w-[37.5%]">
            <img
              src="assets/images/kyverno-square.svg"
              alt="Kyverno logo"
              className="h-6 w-6 sm:h-10 sm:w-10 flex-shrink-0"
              loading="lazy"
            />
            <span>Kyverno</span>
          </th>
          <th className="flex items-center space-x-4 px-4 sm:px-0 sm:w-[37.5%]">
            <img
              src="assets/images/opa.svg"
              alt="Open Policy Agent logo"
              className="h-6 w-6 sm:h-10 sm:w-10 flex-shrink-0"
              loading="lazy"
            />
            <span className="hidden sm:inline">Open Policy Agent</span>
            <span className="sm:hidden">OPA</span>
          </th>
          <th className="flex items-center space-x-4 px-4 sm:px-0 sm:w-[37.5%]">
            <svg
              className="h-6 w-6 sm:h-10 sm:w-10 flex-shrink-0"
              viewBox="0 0 24 24"
              fill="none"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path
                d="M12 2L20 7V17L12 22L4 17V7L12 2Z"
                fill="#326CE5"
                stroke="#326CE5"
                strokeWidth="0.5"
              />
              <path d="M12 4L18.5 8V16L12 20L5.5 16V8L12 4Z" fill="white" />
              <circle cx="12" cy="12" r="2.5" fill="#326CE5" />
              <path d="M12 9.5L13.5 11L12 12.5L10.5 11L12 9.5Z" fill="white" />
              <path
                d="M13.5 13L12 14.5L10.5 13L12 11.5L13.5 13Z"
                fill="white"
              />
            </svg>
            <span>K8s Policy Types</span>
          </th>
        </tr>
      </thead>
      <tbody className="w-full">
        {data.map(
          (
            {
              feature,
              kyverno,
              opa,
              kubernetesNative,
              kyvernoStatus,
              opaStatus,
              kubernetesNativeStatus,
            },
            index,
          ) => (
            <tr
              key={feature}
              className={`w-full flex flex-col sm:flex-row sm:justify-between items-start 
                sm:items-center gap-4 sm:gap-8 rounded-xl min-h-[80px] py-4 ${
                  index % 2 === 0 ? 'bg-stroke' : 'bg-dark-50'
                }`}
            >
              <td className="font-bold w-full sm:w-[30%] px-4 sm:px-0 sm:pl-6 flex items-center">
                {feature}
              </td>

              <td className="w-full sm:contents">
                <div className="flex flex-col sm:contents gap-4">
                  {/* Kyverno */}
                  <div className="flex items-center px-4 sm:px-0 sm:w-[37.5%]">
                    <CellContent text={kyverno} status={kyvernoStatus} />
                  </div>

                  {/* OPA */}
                  <div className="flex items-center px-4 sm:px-0 sm:w-[37.5%]">
                    <CellContent text={opa} status={opaStatus} />
                  </div>

                  {/* Kubernetes Native Policies */}
                  <div className="flex items-center px-4 sm:px-0 sm:w-[37.5%]">
                    <CellContent
                      text={kubernetesNative}
                      status={kubernetesNativeStatus}
                    />
                  </div>
                </div>
              </td>
            </tr>
          ),
        )}
      </tbody>
    </table>
  )
}

// Section parent component
export const ComparisonSection = () => {
  return (
    <section className="flex flex-col justify-center items-center pb-6 px-6">
      <div className="w-full max-w-[1200px]">
        {/* Titre et description */}
        <div className="items-center flex flex-col space-y-6 my-5">
          <h2 className="text-4xl font-bold tracking-wide capitalize text-center">
            Kyverno vs
            <span className="text-primary-100"> Other policy engines</span>
          </h2>
          <p className="min-w-80 text-[1rem] w-80 sm:text-lg sm:min-w-150 text-center text-theme-tertiary">
            As the industry's leading policy engine, here's how Kyverno compares
            with other policy engines.
          </p>
        </div>

        {/* Tableau */}
        <div className="flex justify-center items-center w-full bg-dark-50 border border-stroke p-6 rounded-2xl sm:overflow-x-auto text-[16px] mt-8">
          <Table />
        </div>
      </div>
    </section>
  )
}
