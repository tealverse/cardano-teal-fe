import React, { ReactElement } from 'react';

export type ColumnCfg = {
  label: string;
  selector: string;
  sortable: boolean;
};

type SortableTableProps = {
  columns: Array<ColumnCfg>;
  data: Array<{ [key: string]: string | ReactElement | number }> | Array<never>;
};

export const SortableTable = ({
  columns,
  data,
}: SortableTableProps): ReactElement => {
  return (
    <table>
      <tr>
        {columns.map(col => {
          return <th>{col.label}</th>;
        })}
      </tr>
      {data.length > 0 ? (
        data.map(d => (
          <tr>
            {columns.map(col => {
              const x = d[col.selector];
              return <td>{d[col.selector]}</td>;
            })}
          </tr>
        ))
      ) : (
        <tr>
          <td>No data!</td>
        </tr>
      )}
    </table>
  );
};
