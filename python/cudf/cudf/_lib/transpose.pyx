# Copyright (c) 2019, NVIDIA CORPORATION.

# cython: profile=False
# distutils: language = c++
# cython: embedsignature = True
# cython: language_level = 3

from cudf._lib.cudf cimport *
from cudf._lib.cudf import *
from libc.stdlib cimport free
from libcpp.vector cimport vector

from cudf.core.column import column_empty
from cudf.core.buffer import Buffer
from cudf.utils.dtypes import is_categorical_dtype

cimport cudf._lib.includes.transpose as cpp_transpose


def transpose(df):
    """Transpose index and columns.

    See Also
    --------
    cudf.core.DataFrame.transpose
    """

    if len(df.columns) == 0:
        return df

    dtype = df.dtypes.iloc[0]
    d_type = pd.api.types.pandas_dtype(dtype)
    if is_categorical_dtype(d_type):
        raise NotImplementedError('Categorical columns are not yet '
                                  'supported for function')
    elif d_type.kind in 'OU':
        raise NotImplementedError('String columns are not yet '
                                  'supported for function')

    if any(t != dtype for t in df.dtypes):
        raise ValueError('all columns must have the same dtype')
    has_null = any(c.null_count for c in df._cols.values())

    out_df = cudf.DataFrame()

    ncols = len(df.columns)
    cdef vector[gdf_column*] cols
    for col in df._cols:
        cols.push_back(column_view_from_column(df[col]._column))

    new_nrow = ncols
    new_ncol = len(df)

    new_col_series = [
        cudf.Series(column_empty(new_nrow, dtype=dtype, masked=has_null))
        for i in range(0, new_ncol)
    ]

    cdef vector[gdf_column*] new_cols
    for i in range(0, new_ncol):
        new_cols.push_back(column_view_from_column(new_col_series[i]._column))

    with nogil:
        result = cpp_transpose.gdf_transpose(
            ncols,
            cols.data(),
            new_cols.data()
        )

    for i in range(ncols):
        free(cols[i])
    for i in range(new_ncol):
        free(new_cols[i])

    check_gdf_error(result)

    for series in new_col_series:
        series._column._update_null_count()

    for i in range(0, new_ncol):
        out_df[str(i)] = new_col_series[i]
    return out_df
